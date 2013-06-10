package gr.agroknow.metadata.transformer.dc2agrif;

import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

public class Singleton {
	
	private static Singleton instance ;
	private JSONObject converter ;
	
	Singleton()
	{
		String map = "{\"abstract or summary\":\"landingPage\",\"chart\":\"illustration\",\"database\":\"dataset\",\"graphic\":\"illustration\",\"microscope slide\":\"illustration\",\"numeric data\":\"dataset\",\"picture\":\"illustration\",\"remote sensing image\":\"illustration\",\"slide\":\"illustration\",\"statistics\":\"dataset\",\"technical drawing\":\"illustration\"}" ;
		converter = (JSONObject)JSONValue.parse( map ) ;
	}
	
	public static Singleton getInstance()
	{
		if ( instance == null )
		{
			instance = new Singleton() ;
		}
		return instance ;
	}
	
	public String getPublicationStatus( String genre )
	{
		String g = genre.toLowerCase() ;
		if ( "workingpaper".equals( genre ) || "working paper".equals( genre ) )
		{
			return "Unpublished" ;
		}
		else if ( "pre-print".equals( genre ) || "preprint".equals( genre ) )
		{
			return "Unpublished" ;
		}
		else
		{
			return null ;
		}
	}
	
	public String getManifestationType( String genre )
	{
		String g = genre.toLowerCase() ;
		if ( converter.containsKey( g ) )
		{
			return (String) converter.get( g ) ;
		}
		else
		{
			return null ;
		}
	}

}
