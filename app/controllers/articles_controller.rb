class ArticlesController < ApplicationController

	# get the chromedriver for development
	# chromedriver_path = File.join(File.absolute_path('../..', File.dirname(__FILE__)),"chromedriver")
	# Selenium::WebDriver::Chrome.driver_path = chromedriver_path
	# our browser variable
	@@browser = nil
	# time to crawl
	@@time_taken_to_crawl = 0


	def new
	end

	# display the last inserted articles
	def index
		@articles=Article.last(session[:last_inserted])
		# tttc => time taken to crawl
		@tttc = @@time_taken_to_crawl
		# get search history
		@history=History.all
	end

	# display details of a particular article
	def show
		@article=Article.find(params[:id])
	end

	# get next 10 articles for a particular tag
	def next
		# scroll the browser down to load next 10 articles
		@@browser.send_keys :control, :end
		sleep(0.7)
		# session variable to store the number of articles inserted during latest crawl
		session[:last_inserted] = 0
		crawl
		redirect_to articles_path
	end

	# executed when user search's a tag
	def create
		# get start time
		start_time = Time.now.getutc
		@@browser=Watir::Browser.new :phantomjs

		if params[:search]
			tag=params[:search]
			# store search history
			History.create(
					searchtag: tag
					)
			@@browser.goto("https://medium.com/tag/"+tag)
			session[:count] = 0
			session[:last_inserted] = 0
			crawl

		# get finish time
		finish_time = Time.now.getutc
		# time taken = finish_time - start_time
		@@time_taken_to_crawl = finish_time - start_time
		redirect_to articles_path

		end
	end

	private

	# logic to crawl the data
	def crawl
		@divs = @@browser.divs(:class => "cardChromeless u-marginTop20 u-paddingTop10 u-paddingBottom15 u-paddingLeft20 u-paddingRight20")
		if @divs.length<=session[:count]
			return
		end
		@divs[session[:count]..-1].each do |a|
			

			# get details for each article
			content=[]
			name=(a.a(:class => "ds-link ds-link--styleSubtle link link--darken link--accent u-accentColor--textNormal u-accentColor--textDarken").text)
			time=(a.span(:class => "readingTime").title)
			title=((a.div(:class => "section-inner sectionLayout--insetColumn")).h3.text)
			date=(a.time().text)
			article_link = a.a(:class => "button button--smaller button--chromeless u-baseColor--buttonNormal")

			browser_inner = Watir::Browser.new :phantomjs
			browser_inner.goto(article_link.href)
			# article_link.click(:command, :shift)
			# @@browser.windows.last.use

			# @@browser.ps().each do |para|
			browser_inner.ps().each do |para|
				content.append(para.text)
			end	

			# store article name, title, date, time, content
			article = Article.create(
				name: name,
				title: title,
				date: date,
				time: time,
				content: content
				)

			# store tags related to that article
			# @@browser.as(:href, /tag/).each do |tag|
			browser_inner.as(:href, /tag/).each do |tag|
				Tag.create(
					article_id: article.id,
					tagname: tag.text
					)
			end

			# store responses of that article
			# @@browser.as(href: /responses/).each do |res|
			browser_inner.as(href: /responses/).each do |res|
				browser_inner.goto(res.href)
				sleep(0.7)
				browser_inner.send_keys :control, :end
				
				
				browser_inner.ps(:class => "graf graf--p graf--leading graf--trailing").each do |resp|
					Response.create(
						article_id: article.id,
						responseContent: resp.text
						)
				end	
			end		

			
			session[:count] = session[:count]+1
			session[:last_inserted] = session[:last_inserted] + 1
			# @@browser.windows.last.close
			browser_inner.close
			# @@browser.back
		end
		@@browser.send_keys :control, :end
		sleep(0.7)
	end
	
end
