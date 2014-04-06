#!/bin/env ruby
# encoding: utf-8

module ApplicationHelper
  
  def PaintMenu
    ret = ""
    categs = Category.roots
    if categs.count > 0
      for cat in  categs
        ret += "<li><a href="">#{cat.name}</a>"
        
        ret += AddImages(cat)
        
        ret += AddSubMenu(cat)
        
        ret += "</li>"
      end
      
    end
    
    return sanitize(ret)
  end
  
  def AddImages(cat)
    ret ="<div>"
    
    if(cat.children.count > 0)
      for ch in cat.children
        if(ch.header)
          ret += sanitize("<div style='left: 0px;'></div>")
          
          #ret += sanitize("<div style=" + '"' + "background-image: url(" +'"' + "/Plisset.png" +'"' + ");" +'"' + "></div>")
        end
      end
    end
    
    ret +="</div>"
    return ret
  end
  
  def AddSubMenu(cat)
    ret ="<ul>"
    
    if(cat.children.count > 0)
      for ch in cat.children
        ret += sanitize("<li>" + link_to( ch.name , { :controller => '/catalog', :action => :index, :category_scode => ch.scode} ) + "</li>")
      end
    end
    
    ret +="</ul>"
    return ret
  end
  
  def PaintTree(adm)
    ret = ""
    categs = Category.roots
    if categs.count > 0
    	if adm
    	  ret = "<ul id='categories'>"
  	  else
  	    ret = "<ul>"
  	  end
    	for cat in  categs
    		ret += PaintTreeChildrens(cat, adm, true)
    	end
    	ret += "</ul>"
    end
    return ret
  end
  
  def AddEdit(cat)
     ret = link_to(cat.name, cat)
     if(current_user && current_user.admin?)
        ret += sanitize(" | " + link_to('new', { :controller => :categories, :action => :new , :parent_id => cat.id }))
        ret += sanitize(" | " + link_to('edit', edit_category_path(cat)))
        ret += sanitize(" | " + link_to('del', cat, :confirm => 'Вы уверены?', :method => :delete))
      end
      return ret
  end
  
  def PaintTreeChildrens(cat, adm, root)
      
    if(!adm)
      if(root)
          ret = "<li class='root'>"
        else
          ret = "<li>"
        end
    else
        ret = "<li id='category_#{cat.id}'> <span class='handle'>[drag]</span>"
    end
      
    if(cat.children.count > 0)
      if(adm)
        ret += AddEdit(cat)
      else
        ret += cat.name
      end
      
      ret += "<ul>"
      for ch in cat.children
        ret +=  PaintTreeChildrens(ch, adm , false)
      end
      ret += "</ul>"
    else
      if(adm)
        ret += AddEdit(cat)
      else
        ret += link_to(cat.name, "/" + cat.scode)
      end
    end        
        
    ret += "</li>"
    return ret
  end
end
