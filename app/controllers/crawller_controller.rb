class CrawllerController < ApplicationController

	chromedriver_path = File.join(File.absolute_path('../..', File.dirname(__FILE__)),"chromedriver")

	Selenium::WebDriver::Chrome.driver_path = chromedriver_path


	def index

		browser = Watir::Browser.new :chrome
		browser.goto("https://medium.com/tag/culture")
		# browser.send_keys :control, :end
		# sleep(0.7)
		# @links=browser.links
		@link=[]
		@tag = []
		@c = []
		@content = []
		@responses = []
		

		browser.divs(:class => "cardChromeless u-marginTop20 u-paddingTop10 u-paddingBottom15 u-paddingLeft20 u-paddingRight20").each do |a|
			
			name=(a.a(:class => "ds-link ds-link--styleSubtle link link--darken link--accent u-accentColor--textNormal u-accentColor--textDarken").text)
			time=(a.span(:class => "readingTime").title)
			title=((a.div(:class => "section-inner sectionLayout--insetColumn")).h3.text)
			date=(a.time().text)
			article_link = a.a(:class => "button button--smaller button--chromeless u-baseColor--buttonNormal")
			@c.append(article_link.href)
			article_link.click

			# article = Article.create(
			# 	name: name,
			# 	title: title,
			# 	date: date,
			# 	time: time
			# 	)

			# @c.append(browser.as(:href, /tagged/).length)
			# browser.as(:href, /tagged/).each do |tag|
			# 	@tag.append(tag.text)
			# 	Tag.create(
			# 		article_id: article.id,
			# 		tagname: tag.text
			# 		)

			# end

			browser.ps().each do |para|
				@content.append(para.text)
			end	
			
			# browser.as(href: /responses/).each do |res|
			# 	@responses.append(res.href)
			# 	res.click
			# 	browser.back
			# end
				# response.click
			# browser.ps(:class => "graf graf--p graf--leading graf--trailing").each do |res|
			# 	responses.append(res.text)
			# end
				# end
			



			browser.back
		end
		@articles=Article.all


		# browser.as(:class => "ds-link ds-link--styleSubtle link link--darken link--accent u-accentColor--textNormal u-accentColor--textDarken").each do |a|
		# 	@name.append(a.text)
		# end

		# browser.spans(:class => "readingTime").each do |a|
		# 	@time.append(a.title)
		# end

		# browser.h3s(:class => "graf graf--h3 graf-after--figure graf--title").each do |a|
		# 	@title.append(a.text)
		# end

		# browser.times().each do |a|
		# 	@date.append(a.text)
		# end

		# browser.h4s(:class => "graf graf--h4 graf-after--h3 graf--trailing graf--subtitle").each do |a|
		# 	@blog.append(a.text)
		# end



	end

end
