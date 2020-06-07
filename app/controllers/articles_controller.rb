class ArticlesController < ApplicationController

	# get the chromedriver for development
	chromedriver_path = File.join(File.absolute_path('../..', File.dirname(__FILE__)),"chromedriver")
	Selenium::WebDriver::Chrome.driver_path = chromedriver_path
	# our browser variable
	@@browser = nil
	# time to crawl
	@@time_taken_to_crawl = 0


	def new
	end

	# display the last inserted articles
	def index

		@tag = params[:search]
		last_inserted = Sess.find_by_variable("last_inserted").value.to_i
		puts last_inserted
		@articles=Article.last(last_inserted)
		# tttc => time taken to crawl
		@tttc = Sess.find_by_variable("finish_time").value.to_i-Sess.find_by_variable("start_time").value.to_i
		# get search history
		@history=History.all
	end

	# display details of a particular article
	def show
		@article=Article.find(params[:id])
	end

	# get next 10 articles for a particular tag
	def next
		# # scroll the browser down to load next 10 articles
		# prev=0
		# while @@browser.divs(:class => "cardChromeless u-marginTop20 u-paddingTop10 u-paddingBottom15 u-paddingLeft20 u-paddingRight20").length<=session[:count]
		# 	if prev==@@browser.divs(:class => "cardChromeless u-marginTop20 u-paddingTop10 u-paddingBottom15 u-paddingLeft20 u-paddingRight20").length
		# 		break
		# 	end
		# 	prev=@@browser.divs(:class => "cardChromeless u-marginTop20 u-paddingTop10 u-paddingBottom15 u-paddingLeft20 u-paddingRight20").length
		# 	@@browser.send_keys :control, :end
		# 	sleep(2)
		# end
		# # session variable to store the number of articles inserted during latest crawl
		# session[:last_inserted] = 0
		# crawl
		Sess.find_by_variable("start_time").update_attribute(:value, "0")
		Sess.find_by_variable("finish_time").update_attribute(:value, "0")
		GetMediumDataJob.perform_later params[:search], "next"
		redirect_to articles_path(search: params[:search])
	end

	# executed when user search's a tag
	def create
		# get start time
		# start_time = Time.now.getutc
		# if @@browser==nil
		# 	@@browser=Watir::Browser.new :chrome
		# end

		Sess.destroy_all
		Sess.create([{variable: "count",value: "0"},
					 {variable: "last_inserted",value: "0"},
					 {variable: "start_time",value: "0"},
					 {variable: "finish_time",value: "0"}])


		if params[:search]
			tag=params[:search]
			# store search history
			History.create(
					searchtag: tag
					)

			GetMediumDataJob.perform_later tag, "create"
			# @@browser.goto("https://medium.com/tag/"+tag)
			# session[:count] = 0
			# session[:last_inserted] = 0
			# crawl

		# get finish time
		# finish_time = Time.now.getutc
		# time taken = finish_time - start_time
		# @@time_taken_to_crawl = finish_time - start_time
		redirect_to articles_path(search: tag)

		end
	end

	private

	# logic to crawl the data
	# def crawl
	# 	@divs = @@browser.divs(:class => "cardChromeless u-marginTop20 u-paddingTop10 u-paddingBottom15 u-paddingLeft20 u-paddingRight20")
	# 	if @divs.length<=session[:count]
	# 		return
	# 	end
	# 	loop_var=session[:count]
	# 	len=@divs.length
	# 	@divs[loop_var..loop_var+len].each do |a|

	# 		while a.present? == false
	# 			@@browser.send_keys :control, :end
	# 			sleep(2)
	# 		end

	# 		# get details for each article
	# 		content=[]
	# 		name=(a.a(:class => "ds-link ds-link--styleSubtle link link--darken link--accent u-accentColor--textNormal u-accentColor--textDarken").text)
	# 		time=(a.span(:class => "readingTime").title)
	# 		title=((a.div(:class => "section-inner sectionLayout--insetColumn")).h3.text)
	# 		date=(a.time().text)
	# 		article_link = a.a(:class => "button button--smaller button--chromeless u-baseColor--buttonNormal")

	# 		# browser_inner = Watir::Browser.new :chrome
	# 		# browser_inner.goto(article_link.href)
	# 		article_link.click
	# 		# @@browser.windows.last.use

	# 		@@browser.ps().each do |para|
	# 		# browser_inner.ps().each do |para|
	# 			content.append(para.text)
	# 		end	

	# 		# store article name, title, date, time, content
	# 		article = Article.create(
	# 			name: name,
	# 			title: title,
	# 			date: date,
	# 			time: time,
	# 			content: content
	# 			)

	# 		# store tags related to that article
	# 		@@browser.as(:href, /tag/).each do |tag|
	# 		# browser_inner.as(:href, /tag/).each do |tag|
	# 			Tag.create(
	# 				article_id: article.id,
	# 				tagname: tag.text
	# 				)
	# 		end

	# 		# store responses of that article
	# 		@@browser.as(href: /responses/).each do |res|
	# 		# browser_inner.as(href: /responses/).each do |res|
	# 			@@browser.goto(res.href)
	# 			sleep(0.7)
	# 			@@browser.send_keys :control, :end
				
				
	# 			@@browser.ps(:class => "graf graf--p graf--leading graf--trailing").each do |resp|
	# 				Response.create(
	# 					article_id: article.id,
	# 					responseContent: resp.text
	# 					)
	# 			end	
	# 			@@browser.back
	# 		end		
			
			
	# 		@@browser.back
	# 		@@browser.cookies.clear



	# 		session[:count] = session[:count]+1
	# 		session[:last_inserted] = session[:last_inserted] + 1
			
	# 	end
	# end
	
end
