# encoding: utf-8

class MainController < ApplicationController
  rescue_from Exception, with: :not_found

  def not_found
    @title = "404 Страница не найдена"
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
    @first_banners = banners.find_all{|b| !b.second_line and !b.third_line and !b.fourth_line and !b.square_third}
    @second_banners = banners.find_all{|b| b.second_line}
    @third_banners = banners.find_all{|b| b.third_line}
    @fourth_banners = banners.find_all{|b| b.fourth_line}
    @square_third = banners.find_all{|b| b.square_third}
    @title = "Мебель из шпона - купить корпусную мебель в Москве в интернет-магазине мебели PARRA-SHOP"
    @seo_description = "Интернет-магазин корпусной мебели PARRA-SHOP предлагает купить мебель из шпона по доступным ценам. Мебель Парра - европейский бренд корпусной мебели для дома."
    @seo_keywords = "мебель, шпон, москва, парра, интернет, магазин, корпусный, купить, parra"
  end

  def sitemap
    @title = 'Карта сайта'
    @seo_keywords = 'карта, сайт'
    @seo_description = 'Внимательно ознакомьтесь с картой нашего сайта и Вы несомненно найдете для себя мебель Вашей мечты. Качество, удобство и элегантный стиль.'    
  end
  
  def main
    @products = Product.all
  end

  def spalni
    @title = "Спальные гарнитуры - купить спальню от производителя или корпусную мебель для спальни в Москве в интернет-магазине мебели PARRA-SHOP"
    @seo_description = "Продажа спальных гарнитуров в Москве в интернет-магазине мебели PARRA-SHOP. У нас можно купить спальню от производителя Парра по привлекательной цене."
    @seo_keywords = "гарнитур, спальня, москва, производитель, мебель, интернет, магазин, спальный, корпусный, купить"
  end
  def gostinaya
    @title = "Мебель для гостиной - купить набор корпусной мебели в гостиную комнату в Москве в интернет-магазине мебели PARRA-SHOP"
    @seo_description = "Большой выбор мебели для гостиной комнаты от европейского бренда Парра. На сайте интернет-магазина мебели PARRA-SHOP Вы можете купить набор корпусной мебели в гостиную с доставкой по Москве."
    @seo_keywords = "мебель, москва, комната, набор, гостиный, корпусный, купить"
  end
  def prihozhie
    @title = "Современная мебель для прихожей - купить набор корпусной модульной мебели для прихожей комнаты на заказ в Москве"
    @seo_description = "Интернет-магазин Parra-Shop предлагает купить современную мебель для прихожей. В продаже есть наборы модульной корпусной мебели, стенки для гостиной комнаты. Вы можете приобрести мебель для гостиной на заказ в Москве"
    @seo_keywords = "мебель, москва, комната, заказ, набор, стенка, корпусный, прихожей, модульный, современный, купить"
  end
  def divani
    @title = "Европейские диваны в современном стиле в Москве от интернет магазина Parra-Shop"
    @seo_description = "В интернет магазине Parra-Shop можно купить  диваны в современном стиле. Купить диван в Москве и области."
    @seo_keywords = "Европейские, диваны, современном, стиле, Москве, интернет, магазина, Parra-Shop"
  end
  def matras
    @title = "Матрасы - купить матрас в Москве от компании Parra"
    @seo_description = "Большой выбор матрасов в каталоге интернет-магазина мебели PARRA-SHOP. Актуальные предложения и цены смотрите в нашем каталоге."
    @seo_keywords = "матрас, купить, москва, компания, parra"
  end
  
  def news
    @title = "Новости интернет магазина европейской мебели Parra-Shop"
    @seo_description = "Новости от интернет магазина европейской мебели Parra-Shop"
    @seo_keywords = "Новости, интернет, магазина, европейской, мебели, Parra-Shop"
  end

  def cart
    @title = "Корзина - интернет-магазин мебели из шпона Parra-Shop"
    @seo_description = "Выбранные Вами товары добавляются в корзину интернет-магазина европейской мебели из шпона Parra-Shop. Ваш заказ ожидает оформления."
    @seo_keywords = "Parra, Парра, мебель, шпон, Москва, магазин, доставка, корзина"  	
  end

  def cartjson
  	@product = Product.find_by_name params[:name]
  	render json: @product
  end

  def service
    @title = 'Условия доставки и сборки мебели - интернет-магазин Parra-Shop'
    @seo_keywords = 'условия, доставка, сборка, мебель, расценки, москва, мкад, 5, км'
    @seo_description = 'Профессиональная доставка мебели по Москве и в пределах 5 км от МКАД. С расценками Вы сможете ознакомиться на сайте.'
  end

  def partners
    @title = 'Виды сотрудничества для партнеров - интернет-магазин Parra-Shop'
    @seo_keywords = 'вид, сотрудничество, партнер, дилер, дистрибьютор, агент'
    @seo_description = 'Выгодные условия сотрудничества для дилеров, дистрибьюторов и агентов. Ощутите все преимущества работы с нами.'
  end
  
  def contacts
    @title = "Контакты | интернет-магазин «Parra-Shop»"
    @seo_keywords = 'Контакты' 
    @seo_description = "Контакты | интернет-магазин «Parra-Shop»"
  end

  def new
    @title = 'Новости от нашей компании - интернет-магазин Parra-Shop'
    @seo_keywords = 'новости'
    @seo_description = 'Прекрасная новость - открытие нового салона мебели «PARRA» в ТРК «Красный Кит». Посетите и убедитесь в преимуществе продукции нашего интернет-магазина.'
  end

  def articles
    @title = 'Правила эксплуатация и рекомендации по уходу за мебелью - интернет-магазин Parra-Shop'
    @seo_keywords = 'правила, эксплуатация, рекомендации, уход, мебель'
    @seo_description = 'Уважаемые клиенты, просим обратить пристальное внимание к нашим правилам и рекомендациям. Наша мебель проста в эксплуатации, стильна, надежна и практична.'
  end

  def insurance
    @title = 'Гарантийное обслуживание - интернет-магазин Parra-Shop'
    @seo_keywords = 'гарантийное, обслуживание, срок, изделия, 24, месяц'
    @seo_description = 'Мы имеем собственную службу качества, которая ведет контроль за всеми производственными участками. Гарантийный срок на все изделия - 24 месяца.'
  end

  def stores
    @title = 'Где купить — ParraShop Адреса магазинов где Вы можете купить мебель от ParraShop в Москве'
    @seo_description = 'Адрес магазина европейской мебели ParraShop в Москве'
    @seo_keywords = 'Где, купить, ParraShop, заголовок, Адреса, магазинов, где, Вы, можете, купить, мебель, ParraShop, Москве'
  end

  def store1
    @title = 'Салон магазина европейской мебели ParraShop по адресу МЦ "Мебель PARK" в Москве'
    @seo_description = 'Адрес салона магазина европейской мебели ParraShop в Москве МЦ "Мебель PARK"'
    @seo_keywords = 'Бутик, магазина, европейской, мебели, ParraShop, адресу, МЦ, "Мебель, PARK", Москве'
  end
  
  def store2
    @title = 'Мебель parra-shop в мебельном гипермаркете Family Room.'
    @seo_description = 'Мебель производства фабри Новомебель и вся продукция интерне магазина parra-shop в магазинах москвы. Тел. 8-800-707-67-57 звонок бесплатный по России.'
  end

  def store3
    @title = 'Мебель Parra-Shop в ТК «Армада» в Москве - адрес, время работы и схема проезда'
    @seo_keywords = 'мебель, адрес, время, работа, схема, проезд, москва'
    @seo_description = 'Узнать, где представлены товары интернет-магазина Parra-Shop, Вы сможете на нашем сайте. Мы поможем выбрать мебель по Вашему вкусу.'
  end

  def store4
    @title = 'Мебель Parra-Shop в ТЦ «Черемушки» в Москве: адрес, схема проезда, время работы'
    @seo_keywords = 'мебель, тц, черемушки, адрес, схема, проезд, время, работа, москва'
    @seo_description = 'Наша мебель представлена в ТЦ «Черемушки» по ул. Профсоюзной, д. 56, на третьем этаже. Качественная мебель для Вашего дома.'
  end

  def store5
    @title = 'Мебель Parra-Shop в ТЦ «Roomer» в Москве - наш адрес и время работы'
    @seo_keywords = 'мебель, тц, roomer, адрес, время, работа, москва'
    @seo_description = 'Мебель нашего интернет-магазина представлена в ТЦ «Roomer», который находится по ул. Ленинская Слобода, д. 26. Красивая мебель из Литвы в Москве.'
  end

  def store6
    @title = 'Мебель Parra-Shop в ТК «Твой дом» на 66 км МКАД Москвы - адрес и схема проезда'
    @seo_keywords = 'мебель, тк, твой, дом, 66, км, мкад, адрес, схема, проезд, москва'
    @seo_description = 'На 66 км МКАД в ТК «Твой дом» Вы всегда сможете посмотреть мебель, которая есть в нашем интернет-магазине. Parra-Shop следит за качеством всей своей продукции.'
  end

  def store7
    @title = 'Мебель и гарнитуры Parra-Shop в ТРК «Красный кит» - адрес в Мытищах и подробная схема проезда'
    @seo_keywords = 'мебель, гарнитуры, трк, красный, кит, адрес, подробная, схема, проезд, Мытищи'
    @seo_description = 'Мебель интернет-магазина Parra-Shop всегда можно посмотреть, посетив ТРК «Красный кит» в городе Мытищи. Работаем с 10:00 до 20:00 без обеда и выходных.'
  end

  def store8
    @title = 'Мебель Parra-Shop в МЦ «Вагант» в Подольске - адрес и карта проезда'
    @seo_keywords = 'мебель, мц, вагант, Подольск, адрес, карта, проезд'
    @seo_description = 'В Подольске Московской области представлена продукция нашего интернет-магазина. Посетите МЦ «Вагант» и выберите мебель по своему вкусу.'
  end
  def store9
    @title = 'Мебель Parra-Shop в МЦ «Империя» - адрес в Москве и карта проезда'
    @seo_keywords = 'мебель, мц, империя, адрес, москва, карта, проезд'
    @seo_description = 'Мебель для вашего дома представлена в МЦ «Империя». Продукция нашего интернет-магазина - это высочайшее качество, стиль и комфорт.'
  end
  def otzyvy
    @title = 'Отзывы покупателей о мебели parra, производства - Новомебель.'
    @seo_description = 'Читаем и пишем новые отзывы о мебельной продукции PARRA, производства Новомебель.'
    @seo_keywords = 'мебель parra отзывы.'
  end
  def about
    @title = "О компании - интернет-магазин Parra-Shop"
    @seo_keywords = 'Мебель Парра создается европейскими дизайнерами, которые учитывают последние тенденции в мире мебельной моды. Новейшие технологии и качество продукции.'
    @seo_description = 'компания, мебель, парра'
  end
end
