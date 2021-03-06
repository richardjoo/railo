/**
 * Implements the CFML Function createobject
 * FUTURE neue attr unterst�tzen
 */
package railo.runtime.functions.other;

import java.util.ArrayList;

import railo.commons.io.res.Resource;
import railo.commons.io.res.util.ResourceUtil;
import railo.commons.lang.ClassUtil;
import railo.commons.lang.StringUtil;
import railo.runtime.Component;
import railo.runtime.PageContext;
import railo.runtime.com.COMObject;
import railo.runtime.config.ConfigImpl;
import railo.runtime.exp.ExpressionException;
import railo.runtime.exp.FunctionNotSupported;
import railo.runtime.exp.PageException;
import railo.runtime.exp.SecurityException;
import railo.runtime.ext.function.Function;
import railo.runtime.java.JavaObject;
import railo.runtime.listener.JavaSettings;
import railo.runtime.net.proxy.ProxyData;
import railo.runtime.net.proxy.ProxyDataImpl;
import railo.runtime.net.rpc.client.RPCClient;
import railo.runtime.op.Caster;
import railo.runtime.security.SecurityManager;
import railo.runtime.type.List;
import railo.runtime.type.Struct;

public final class CreateObject implements Function {
	public static Object call(PageContext pc , String cfcName) throws PageException {
		return call(pc,"component",cfcName,null,null);
	}
	public static Object call(PageContext pc , String type, String className) throws PageException {
		return call(pc,type,className,null,null);
	}
	public static Object call(PageContext pc , String type, String className, Object context) throws PageException {
		return call(pc,type,className,context,null);
	}
	public static Object call(PageContext pc , String type, String className, Object context, Object serverName) throws PageException {
		type=StringUtil.toLowerCase(type);
		
		
		// JAVA
			if(type.equals("java")) {
			    checkAccess(pc,type);
				return doJava(pc, className,Caster.toString(context),Caster.toString(serverName));
			}
		// COM
			if(type.equals("com")) {
				return doCOM(pc,className);
			}
        // Component
            if(type.equals("component")) {
                return doComponent(pc,className);
            }
        // Webservice
            if(type.equals("webservice") || type.equals("wsdl")) {
            	String user=null;
            	String pass=null;
            	ProxyDataImpl proxy=null;
            	if(context!=null){
            		Struct args=(serverName!=null)?Caster.toStruct(serverName):Caster.toStruct(context);
            		// basic security
            		user=Caster.toString(args.get("username",null));
            		pass=Caster.toString(args.get("password",null));
            		
            		// proxy
            		String proxyServer=Caster.toString(args.get("proxyServer",null));
            		String proxyPort=Caster.toString(args.get("proxyPort",null));
            		String proxyUser=Caster.toString(args.get("proxyUser",null));
            		if(StringUtil.isEmpty(proxyUser)) proxyUser=Caster.toString(args.get("proxyUsername",null));
            		String proxyPassword=Caster.toString(args.get("proxyPassword",null));
            		
            		if(!StringUtil.isEmpty(proxyServer)){
            			proxy=new ProxyDataImpl(proxyServer,Caster.toIntValue(proxyPort,-1),proxyUser,proxyPassword);
            		}            		
            		
            	}
                return doWebService(pc,className,user,pass,proxy);
            }
        // .net
            if(type.equals(".net") || type.equals("dotnet")) {
                return doDotNet(pc,className);
            }
			throw new ExpressionException("invalid argument for function createObject, first argument (type), " +
					"must be (com, java, webservice or component) other types are not supported");
		
	} 

    private static Object doDotNet(PageContext pc, String className) throws FunctionNotSupported {
    	throw new FunctionNotSupported("CreateObject","type .net");
	}
	private static void checkAccess(PageContext pc, String type) throws SecurityException {
        if(pc.getConfig().getSecurityManager().getAccess(SecurityManager.TYPE_TAG_OBJECT)==SecurityManager.VALUE_NO) 
			throw new SecurityException("can't access function [createObject] with type ["+type+"]","access is prohibited by security manager");
		
    }
	
	 
    public static Object doJava(PageContext pc,String className, String pathes, String delimiter) throws PageException {
        if(pc.getConfig().getSecurityManager().getAccess(SecurityManager.TYPE_DIRECT_JAVA_ACCESS)==SecurityManager.VALUE_YES) {
        	ConfigImpl ci = ((ConfigImpl)pc.getConfig());
        	
        	// get java settings from application.cfc
        	java.util.List<Resource> resources=getJavaSettings(pc);
        	
        	// load resources
        	//Resource[] reses=null;
        	if(!StringUtil.isEmpty(pathes, true)) {
        		if(StringUtil.isEmpty(delimiter))delimiter=",";
        		String[] arrPathes = List.trimItems(List.toStringArray(List.listToArrayRemoveEmpty(pathes.trim(),delimiter)));
        		
        		for(int i=0;i<arrPathes.length;i++) {
        			resources.add(ResourceUtil.toResourceExisting(pc,arrPathes[i]));
        		}
        	}
        	
        	// load class
        	try	{
        		ClassLoader cl = resources.size()==0?ci.getClassLoader():ci.getClassLoader(resources.toArray(new Resource[resources.size()]));
    			Class clazz = ClassUtil.loadClass(cl,className);
        		return new JavaObject((pc).getVariableUtil(),clazz);
	        } 
			catch (Exception e) {
				throw Caster.toPageException(e);
			}
        }
        throw new SecurityException("can't create Java Object ["+className+"], direct java access is deinied by security manager");
	} 
    
    public static java.util.List<Resource> getJavaSettings(PageContext pc) {
    	java.util.List<Resource> resources=new ArrayList<Resource>();
    	
    	// get Resources from application context
    	JavaSettings settings=pc.getApplicationContext().getJavaSettings();
    	Resource[] _resources = settings==null?null:settings.getResources();
    	if(_resources!=null)for(int i=0;i<_resources.length;i++){
    		resources.add(_resources[i]);
    	}
    	
		return resources;
	}
	public static Object doCOM(PageContext pc,String className) {
		return new COMObject(className);
	} 
    
    public static Component doComponent(PageContext pc,String className) throws PageException {
    	
    	return pc.loadComponent(className);
    } 
    
    public static Object doWebService(PageContext pc,String wsdlUrl) throws PageException {
    	// TODO CF8 impl. alle neuen attribute f�r wsdl
    	return new RPCClient(wsdlUrl);
    } 
    
    public static Object doWebService(PageContext pc,String wsdlUrl,String username,String password, ProxyData proxy) throws PageException {
    	// TODO CF8 impl. alle neuen attribute f�r wsdl
    	return new RPCClient(wsdlUrl,username,password,proxy);
    } 
}