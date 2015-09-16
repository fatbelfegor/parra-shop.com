# encoding: utf-8

class MainController < ApplicationController
  rescue_from Exception, with: :not_found

  def not_found
    render 'pages/not_found', status: 404
  end
  def index
    @products = Product.all
    if user_signed_in? && current_user.admin?
      @cat = Category.find_by_scode('Диваны').products.order('created_at asc').limit(10)
    else
      @cat = Category.find_by_scode('Диваны').products.where('invisible = false').order('created_at asc').limit(10)
    end
    banners = Banner.all
    @first_banners = banners.find_all{|b| !b.second_line and !b.third_line}
    @second_banners = banners.find_all{|b| b.second_line}
    @third_banners = banners.find_all{|b| b.third_line}
    @title = "ParraShop — мебель parra от Новомебель из Литвы в Москве"
    @seo_description = "Магазин мебель Parra в Москве — ParraShop"
  end

  def sitemap
    @title = 'Карта сайта'    
  end
  
  def main
    @products = Product.all
  end

  def spalni
  end
  def gostinaya
  end
  def divani
  end
  def matras
  end

  def cart  	
  end

  def cartjson
  	@product = Product.find_by_name params[:name]
  	render json: @product
  end

  def Jimmi
  end

  def service
    @title = 'Сборка, доставка мебели из нашего магазина PARRA-SHOP.'
  end

  def partners
    @title = 'Для партнеров, диллеров, агентов.'
  end

  def new
    @title = 'Новости мебели Parra.'
  end

  def articles
    @title = 'Сатьи о мебеле Parra.'
  end

  def insurance
    @title = 'Информация для покупателей о гарантийном обслуживание.'
  end

  def stores
    @title = 'Где купить — ParraShop" и заголовок "Адреса магазинов где Вы можете купить мебель от ParraShop в Москве'
  end

  def store2
    @title = 'Мебель parra-shop в мебельном гипермаркете Family Room.'
    @seo_description = 'Мебель производства фабри Новомебель и вся продукция интерне магазина parra-shop в магазинах москвы. Тел. 8-800-707-67-57 звонок бесплатный по России.'
  end

  def store3
    @title = 'Мебель parra-shop в ТК "Армада"'
    @seo_description = 'Мебель производства фабри Новомебель и вся продукция интерне магазина parra-shop в магазинах москвы. Тел. 8-800-707-67-57 звонок бесплатный по России.'
  end

  def store4
    @title = 'Мебель интернет магазина parra-shop в ТЦ "Черемушки"'
    @seo_description = 'Мебель производства фабри Новомебель и вся продукция интерне магазина parra-shop в магазинах москвы. Тел. 8-800-707-67-57 звонок бесплатный по России.'
  end

  def store5
    @title = 'Мебель parra-shop в ТЦ Roomer'
    @seo_description = 'Мебель производства фабри Новомебель и вся продукция интерне магазина parra-shop в магазинах москвы. Тел. 8-800-707-67-57 звонок бесплатный по России.'
  end

  def store6
    @title = 'Мебель parra-shop в ТК "ТВОЙ ДОМ" на 66 км МКАД'
    @seo_description = 'Мебель производства фабри Новомебель и вся продукция интерне магазина parra-shop в магазинах москвы. Тел. 8-800-707-67-57 звонок бесплатный по России.'
  end

  def store7
    @title = 'Мебель parra-shop в ТРЦ "РИО" Реутов'
    @seo_description = 'Мебель производства фабри Новомебель и вся продукция интерне магазина parra-shop в магазинах москвы. Тел. 8-800-707-67-57 звонок бесплатный по России.'
  end

  def store8
    @title = 'Мебель parra-shop в МЦ "Вагант" Подольск'
    @seo_description = 'Мебель производства фабри Новомебель и вся продукция интерне магазина parra-shop в магазинах москвы. Тел. 8-800-707-67-57 звонок бесплатный по России.'
  end
  def store9
    @title = 'Мебель parra-shop в ТЦ "Империя"'
    @seo_description = 'Мебель производства фабри Новомебель и вся продукция интерне магазина parra-shop в магазинах москвы. Тел. 8-800-707-67-57 звонок бесплатный по России.'
  end
  def otzyvy
    @title = 'Отзывы покупателей о мебели parra, производства - Новомебель.'
    @seo_description = 'Читаем и пишем новые отзывы о мебельной продукции PARRA, производства Новомебель.'
    @seo_keywords = 'мебель parra отзывы.'
  end
  def about
    @title = "О нас"
  end
end
