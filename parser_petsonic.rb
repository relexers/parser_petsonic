require 'nokogiri'
require 'curb'
require 'csv'


#Заносим переданные при запуске параметры в переменные
link = ARGV[0]
filecsv = ARGV[1]
puts ('Обрабатываем полученную информацию')

url_1 = Curl.get(link) #Открываем ссылку

html = Nokogiri::HTML(url_1.body_str) #Парсим ее

url_list = [] #Создаем пустой массив для записи в него ссылок на товары из переданной категории

#Получаем все ссылки на товары из категории и записываем их в созданный ранее массив
puts('Собираем ссылки')
html.xpath('.//a[@class="product-name"]/@href').each do |url|
  url_list << url
end
puts('Собрали')

# открываем(создаем) файл csv,переданный вторым параметром при запуске и указываем названия столбцов
CSV.open(filecsv, "wb") do |csv|
  csv << ['Название', 'Вес/Количество', 'Цена']

  #Открываем полученные ссылки на товары
  url_list.each do |tovar_url|
    www = Curl.get(tovar_url) #Открываем ссылку
    page = Nokogiri::HTML(www.body_str)   #Парсим

    # Получаем нужные нам данные (Название, Вес/Количество, Цена)

    #Название
    title = page.xpath('//*[@id="center_column"]/div/div/div[1]/div[1]/p/text()').text
    puts title

    #Находим возможные варианты веса/количества
    attr_list = page.xpath ( '//*[@id="attributes"]/fieldset/div/ul/li[1]/label/span[1]' )

    attr_list.each do |attr| #Перебираем варианты

      #Создаем переменную x для того чтобы потом записывать варианты по индексу
      x = 0

      #Получаем вес
      weight = attr.xpath ( '//*[@id="attributes"]/fieldset/div/ul/li/label/span[1]/text()' )

      weight.each do |at| #Проходимся по вариантам
        puts at
        # Находим стоимость для конкретного веса/количества
        cost =  attr .xpath ( '//*[@id="attributes"]/fieldset/div/ul/li/label/span[2]/text()' )
        puts cost[x]
        all_str = [title, weight[x] , cost[x]] # сбор данных
        csv << all_str # пишем собранные данные в открытый файл csv
        x += 1 #Увеличиваем индекс
      end
    end
  end
end
