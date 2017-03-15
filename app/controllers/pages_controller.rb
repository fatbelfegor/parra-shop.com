class PagesController < ApplicationController
  rescue_from Exception, with: :not_found

  def not_found
    @title = "404 Страница не найдена"
    render 'pages/not_found', status: 404
  end

  def vacancy
    @title = "Вакансии - работа в компании Parra-Shop: интернет-магазин мебели из шпона в Москве"
    @seo_description = "Актуальные вакансии магазина Parra-Shop. Начните карьеру у нас - телефон для связи +7 (967) 021-37-73."
    @seo_keywords = "Parra, Парра, мебель, шпон, Москва, магазин, вакансии, работа" 
  end

  def loyalty_card
    @title = "Карта лояльности"
  end

  def pokupka_v_kredit
    @title = "Покупка в кредит"
  end

  def sposoby_oplaty
    @title = "Способы оплаты"
  end
end
