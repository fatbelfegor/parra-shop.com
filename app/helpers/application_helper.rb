#!/bin/env ruby
# encoding: utf-8

module ApplicationHelper

  def getCatChildren(parent)
    @cats.find_all{|cat| cat if cat.parent_id == parent.id}
  end
  
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
         # ret += sanitize("<div style='left: 0px;'></div>")
           #ret += "<div style='background:url(/assets/Plisset.png);'></div>"
          #background:url(/images/HeaderMenu.png)
          
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
    	  ret = "<ul id='categories' class='sortable'>"
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
     ret = link_to(cat.name, cat, class: 'col-md-6 btn btn-default')
     if(current_user && current_user.admin?)
        ret += sanitize(link_to('new', { :controller => :categories, :action => :new , :parent_id => cat.id }, class: 'col-md-1 btn btn-success'))
        ret += sanitize(link_to('edit', edit_category_path(cat), class: 'col-md-1 btn btn-warning'))
        ret += sanitize(link_to('del', cat, :confirm => 'Вы уверены?', :method => :delete, class: 'col-md-1 btn btn-danger'))
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
        ret = "<li id='category_#{cat.id}'><div class='row'><span class='handle col-md-1 btn btn-info'>[drag]</span>"
    end
      
    if(cat.children.count > 0)
      if(adm)
        ret += AddEdit(cat)
      else
        ret += cat.name
      end
      
      ret += "</div><ul class='sortable'>"
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
