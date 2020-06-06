class ArticlesController < ApplicationController

	chromedriver_path = File.join(File.absolute_path('../..', File.dirname(__FILE__)),"chromedriver")
	Selenium::WebDriver::Chrome.driver_path = chromedriver_path
	@@browser = nil
	@@time_taken_to_crawl = 0


	def new
	end

	def index
		@articles=Article.all
		@last_inserted = session[:last_inserted]
		@tttc = @@time_taken_to_crawl
		@history=History.all
	end

	def show
		@article=Article.find(params[:id])
	end

	def next
		@@browser.send_keys :control, :end
		sleep(0.7)
		session[:last_inserted] = 0
		crawl
		redirect_to articles_path
	end

	def create
		start_time = Time.now.getutc
		@@browser=Watir::Browser.new :chrome
		if params[:search]
			tag=params[:search]
			History.create(
					searchtag: tag
					)
			@@browser.goto("https://medium.com/tag/"+tag)
			session[:count] = 0
			session[:last_inserted] = 0
			crawl
		finish_time = Time.now.getutc
		@@time_taken_to_crawl = finish_time - start_time
		redirect_to articles_path

		end
	end

	private

	def crawl
		@divs = @@browser.divs(:class => "cardChromeless u-marginTop20 u-paddingTop10 u-paddingBottom15 u-paddingLeft20 u-paddingRight20")
		if @divs.length<=session[:count]
			return
		end
		@divs[session[:count]..-1].each do |a|
			
			content=[]
			name=(a.a(:class => "ds-link ds-link--styleSubtle link link--darken link--accent u-accentColor--textNormal u-accentColor--textDarken").text)
			time=(a.span(:class => "readingTime").title)
			title=((a.div(:class => "section-inner sectionLayout--insetColumn")).h3.text)
			date=(a.time().text)
			article_link = a.a(:class => "button button--smaller button--chromeless u-baseColor--buttonNormal")
			article_link.click(:command, :shift)
			@@browser.windows.last.use

			@@browser.ps().each do |para|
				content.append(para.text)
			end	

			article = Article.create(
				name: name,
				title: title,
				date: date,
				time: time,
				content: content
				)

			@@browser.as(:href, /tag/).each do |tag|
				Tag.create(
					article_id: article.id,
					tagname: tag.text
					)
			end

			
			@@browser.as(href: /responses/).each do |res|
				@@browser.goto(res.href)
				sleep(0.7)
				@@browser.send_keys :control, :end
				
				
				@@browser.ps(:class => "graf graf--p graf--leading graf--trailing").each do |resp|
					Response.create(
						article_id: article.id,
						responseContent: resp.text
						)
				end	
			end		

			
			session[:count] = session[:count]+1
			session[:last_inserted] = session[:last_inserted] + 1
			@@browser.windows.last.close
			# @@browser.back
		end
	end
	
end
