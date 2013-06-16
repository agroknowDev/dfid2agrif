package gr.agroknow.metadata.transformer.dc2agrif;

import gr.agroknow.metadata.agrif.Agrif;
import gr.agroknow.metadata.agrif.Citation;
import gr.agroknow.metadata.agrif.ControlledBlock;
import gr.agroknow.metadata.agrif.Creator;
import gr.agroknow.metadata.agrif.Expression;
import gr.agroknow.metadata.agrif.Item;
import gr.agroknow.metadata.agrif.LanguageBlock;
import gr.agroknow.metadata.agrif.Manifestation;
import gr.agroknow.metadata.agrif.Relation;
import gr.agroknow.metadata.agrif.Rights;
import gr.agroknow.metadata.agrif.Publisher;

import gr.agroknow.metadata.transformer.ParamManager;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;
import java.util.ArrayList;

import net.zettadata.generator.tools.Toolbox;
import net.zettadata.generator.tools.ToolboxException;

%%
%class DC2AGRIF
%standalone
%unicode

%{
	// AGRIF
	private List<Agrif> agrifs ;
	private Agrif agrif ;
	private Citation citation ;
	private ControlledBlock cblock ;
	private Creator creator ;
	private Expression expression ;
	private Item item ;
	private LanguageBlock lblock ;
	private Manifestation manifestation ;
	private Relation relation ;
	private Rights rights ;
	private Publisher publisher ;
	
	// TMP
	private StringBuilder tmp ;
	private String language ;
	private String date = null ;
	private List<Publisher> publishers = new ArrayList<Publisher>() ;
	
	// EXERNAL
	private String providerId ;
	private String manifestationType = "landingPage" ;
	
	public void setManifestationType( String manifestationType )
	{
		this.manifestationType = manifestationType ;
	}
	
	public void setProviderId( String providerId )
	{
		this.providerId = providerId ;
	}
	
	public List<Agrif> getAgrifs()
	{
		return agrifs ;
	}
	
	private void init()
	{
		agrif = new Agrif() ;
		agrif.setSet( providerId ) ;
		citation  = new Citation() ;
		cblock = new ControlledBlock() ;
		expression = new Expression() ;
		expression.setLanguage( "en" ) ;
		lblock = new LanguageBlock() ;
		relation = new Relation() ;
		rights = new Rights() ;
		rights.setIdentifier( "https://www.gov.uk/government/publications/dfid-research-open-and-enhanced-access-policy" ) ;
		rights.setRightsStatement( "en", "The aim of this open access policy is to increase the uptake and use of DFID research." ) ;
		agrif.setRights( rights ) ;
	}
		
	private String utcNow() 
	{
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = new SimpleDateFormat( "yyyy-MM-dd" );
		return sdf.format(cal.getTime());
	}
	
	private String extract( String element )
	{	
		return element.substring(element.indexOf(">") + 1 , element.indexOf("</") );
	}
	
%}

%state AGRIF
%state DESCRIPTION
%state CITATION
%state TITLE

%%

<YYINITIAL>
{	
	
	"<oai_dc:dc"
	{
		agrifs = new ArrayList<Agrif>() ;
		init() ;
		yybegin( AGRIF ) ;
	}
}

<AGRIF>
{
	"</oai_dc:dc>"
	{
		agrif.setExpression( expression ) ;
		agrif.setLanguageBlocks( lblock ) ;
		agrif.setControlled( cblock ) ;
		agrifs.add( agrif ) ;
		yybegin( YYINITIAL ) ;
	}
	
	"<dc:title xmlns:dc=\"http://purl.org/dc/elements/1.1/\">"
	{
		tmp = new StringBuilder() ;
		yybegin( TITLE ) ;
	}

	"<dc:date xmlns:dc=\"http://purl.org/dc/elements/1.1/\">".+"</dc:date>"
	{
		date = extract( yytext() ) ;
		publisher = new Publisher() ;
		publisher.setDate( date.substring(0, 4) ) ;
		expression.setPublisher( publisher ) ;
	}

	"<dc:type xmlns:dc=\"http://purl.org/dc/elements/1.1/\">".+"</dc:type>"
	{
		String type = extract( yytext() ) ;
		cblock.setType( "dcterms", type ) ;
	}
	
		
	"<dc:identifier xmlns:dc=\"http://purl.org/dc/elements/1.1/\">".+".pdf</dc:identifier>"
	{
		manifestation = new Manifestation() ;
		item = new Item() ;
		item.setDigitalItem( extract( yytext() ) ) ;
		manifestation.setManifestationType( "fullText" ) ;
		manifestation.setFormat( "application/pdf" ) ;
		manifestation.setItem( item ) ;
		expression.setManifestation( manifestation ) ;
	}

	"<dc:title xmlns:dc=\"http://purl.org/dc/elements/1.1/\" />"
	{
		// ignore!
	}

	"<dc:identifier xmlns:dc=\"http://purl.org/dc/elements/1.1/\">".+"</dc:identifier>"
	{
		manifestation = new Manifestation() ;
		item = new Item() ;
		item.setDigitalItem( extract( yytext() ) ) ;
		manifestation.setManifestationType( "landingPage" ) ;
		manifestation.setFormat( "text/html" ) ;
		manifestation.setItem( item ) ;
		expression.setManifestation( manifestation ) ;
	}

	
	"<dc:coverage xmlns:dc=\"http://purl.org/dc/elements/1.1/\">".+"</dc:coverage>"
	{
		cblock.setSpatialCoverage( "unknown", extract( yytext() ) ) ;
	}
	
	"<dc:creator xmlns:dc=\"http://purl.org/dc/elements/1.1/\" opf:role=\"aut\">".+".</dc:creator>"
	{
		creator = new Creator() ;
		creator.setName( extract( yytext() ) ) ;
		creator.setType( "person" ) ;
		agrif.setCreator( creator ) ;
	}
	
	"<dc:creator xmlns:dc=\"http://purl.org/dc/elements/1.1/\" opf:role=\"aut\">".+"</dc:creator>"
	{
		creator = new Creator() ;
		creator.setName( extract( yytext() ) ) ;
		// creator.setType( "org" ) ;
		agrif.setCreator( creator ) ;
	}
	
	"<dc:subject xmlns:dc=\"http://purl.org/dc/elements/1.1/\">".+"</dc:subject>"
	{
		String tmptext = extract( yytext() ) ;
		language = ParamManager.getInstance().getLanguageFor( tmptext ) ;
		lblock.setKeyword( language, tmptext ) ;
	}
	
	"<dc:description xmlns:dc=\"http://purl.org/dc/elements/1.1/\">"
	{
		tmp = new StringBuilder() ;
		yybegin( DESCRIPTION ) ;
	}
	
	"<dc:relation xmlns:dc=\"http://purl.org/dc/elements/1.1/\">".+"</dc:relation>"
	{
		relation = new Relation() ;
		relation.setTypeOfRelation( "isPartOf" ) ;
		relation.setTypeOfReference( "URI" ) ;
		relation.setReference( extract( yytext() ) ) ;
		agrif.setRelation( relation ) ;
	}
}

<TITLE>
{
	"</dc:title>"
	{
		String tmptext = tmp.toString() ;
		language = ParamManager.getInstance().getLanguageFor( tmptext ) ;
		yybegin( AGRIF ) ;
		lblock.setTitle( language, tmptext ) ;
	}
	
	.|\n
	{
		tmp.append( yytext() ) ;
 	}

}

<DESCRIPTION>
{
	"</dc:description>"
	{
		yybegin( AGRIF ) ;
		String tmptext = tmp.toString() ;
		language = ParamManager.getInstance().getLanguageFor( tmptext ) ;
		lblock.setAbstract( language, tmptext ) ;
	}
	
	"&lt;br/&gt;"
	{
		tmp.append( " " ) ;
	}
	
	"<![CDATA["|"]]>"
	{
		// ignore !
	}
	
	.
	{
		tmp.append( yytext() ) ; 
	}
	
	\n
	{
		tmp.append( " " ) ;
	}
}

/* error fallback */
.|\n 
{
	//throw new Error("Illegal character <"+ yytext()+">") ;
}
