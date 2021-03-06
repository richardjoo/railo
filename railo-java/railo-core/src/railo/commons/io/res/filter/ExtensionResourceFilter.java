package railo.commons.io.res.filter;


import railo.commons.io.res.Resource;
import railo.commons.lang.StringUtil;

/**
 * Filter f�r die <code>listFiles</code> Methode des FIle Objekt, 
 * zum filtern von FIles mit einer bestimmten Extension.
 */
public final class ExtensionResourceFilter implements ResourceFilter {
	
	private final String[] extensions;
	private final boolean allowDir;
	private final boolean ignoreCase;
    //private int extLen;
	

	/**
	 * Konstruktor des Filters
	 * @param extension Endung die gepr�ft werden soll.
	 */
	public ExtensionResourceFilter(String extension) {
		this(new String[]{extension},false,true);
	}

	/**
	 * Konstruktor des Filters
	 * @param extension Endung die gepr�ft werden soll.
	 */
	public ExtensionResourceFilter(String extension, boolean allowDir) {
		this(new String[]{extension},allowDir,true);
	}
	
	public ExtensionResourceFilter(String[] extensions) {
		this(extensions,false,true);
	}
	
	public ExtensionResourceFilter(String[] extensions, boolean allowDir) {
		this(extensions,allowDir,true);
	}

	
	public ExtensionResourceFilter(String[] extensions, boolean allowDir, boolean ignoreCase) {
		String[] tmp=new String[extensions.length];
		for(int i=0;i<extensions.length;i++) {
			if(!StringUtil.startsWith(extensions[i],'.'))
	            tmp[i]="."+extensions[i];
			else tmp[i]=extensions[i];
		}
		this.extensions=tmp;
    	this.allowDir=allowDir;
    	this.ignoreCase=ignoreCase;
	}

	/**
	 * @see railo.commons.io.res.filter.ResourceFilter#accept(railo.commons.io.res.Resource)
	 */
	public boolean accept(Resource res) {
		if(res.isDirectory()) return allowDir;
		if(res.exists()) {
			String name=res.getName();
			for(int i=0;i<extensions.length;i++) {
				if(ignoreCase){
					if(StringUtil.endsWithIgnoreCase(name,extensions[i]))
						return true;
				}
				else {
					if(name.endsWith(extensions[i]))
						return true;
				}
			}
		}
		return false;
	}
	
    /**
     * @return Returns the extension.
     */
    public String[] getExtensions() {
        return extensions;
    }
}