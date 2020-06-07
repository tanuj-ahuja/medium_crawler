class GetMediumDataJob < ApplicationJob
  	queue_as :default

  	# get the chromedriver for development
	chromedriver_path = File.join(File.absolute_path('../..', File.dirname(__FILE__)),"chromedriver")
	Selenium::WebDriver::Chrome.driver_path = chromedriver_path
	# our browser variable
	# @browser = nil
	# time to crawl
	# @@time_taken_to_crawl = 0

	def perform(tag, type)
	# Do something later 1
		count = Sess.find_by_variable("count").value.to_i
		last_inserted = Sess.find_by_variable("last_inserted").value.to_i
		@browser=Watir::Browser.new :chrome
		@browser.goto("https://medium.com/tag/"+tag)
		sleep(2)
		Sess.find_by_variable("start_time").update_attribute(:value, Time.now.to_i.to_s)

		if type == "create"
			# if @@browser==nil
			# 	@@browser=Watir::Browser.new :chrome
			# end

			
			crawl count, last_inserted
		

	# Do something later 2
	# scroll the browser down to load next 10 articles
		else
			
			prev=0
			while @browser.divs(:class => "cardChromeless u-marginTop20 u-paddingTop10 u-paddingBottom15 u-paddingLeft20 u-paddingRight20").length<=count
				if prev==@browser.divs(:class => "cardChromeless u-marginTop20 u-paddingTop10 u-paddingBottom15 u-paddingLeft20 u-paddingRight20").length
					break
				end
				prev=@browser.divs(:class => "cardChromeless u-marginTop20 u-paddingTop10 u-paddingBottom15 u-paddingLeft20 u-paddingRight20").length
				@browser.send_keys :control, :end
				sleep(2)
			end
			# session variable to store the number of articles inserted during latest crawl
			Sess.find_by_variable("last_inserted").update_attribute(:value, "0")
			crawl count, 0
		end
		Sess.find_by_variable("finish_time").update_attribute(:value, Time.now.to_i.to_s)
		@browser.close
	end


  private

	# logic to crawl the data
	def crawl(count, last_inserted)
		@divs = @browser.divs(:class => "cardChromeless u-marginTop20 u-paddingTop10 u-paddingBottom15 u-paddingLeft20 u-paddingRight20")
		# if @divs.length<=count
		# 	return
		# end
		loop_var=count
		len=@divs.length
		@divs[loop_var..loop_var+len].each do |a|

			while a.present? == false
				@browser.send_keys :control, :end
				sleep(2)
			end

			# get details for each article
			content=[]
			name=(a.a(:class => "ds-link ds-link--styleSubtle link link--darken link--accent u-accentColor--textNormal u-accentColor--textDarken").text)
			time=(a.span(:class => "readingTime").title)
			title=((a.div(:class => "section-inner sectionLayout--insetColumn")).h3.text)
			date=(a.time().text)
			article_link = a.a(:class => "button button--smaller button--chromeless u-baseColor--buttonNormal")

			# browser_inner = Watir::Browser.new :chrome
			# browser_inner.goto(article_link.href)
			article_link.click
			# @@browser.windows.last.use

			@browser.ps().each do |para|
			# browser_inner.ps().each do |para|
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
			@browser.as(:href, /tag/).each do |tag|
			# browser_inner.as(:href, /tag/).each do |tag|
				Tag.create(
					article_id: article.id,
					tagname: tag.text
					)
			end

			# store responses of that article
			@browser.as(href: /responses/).each do |res|
			# browser_inner.as(href: /responses/).each do |res|
				@browser.goto(res.href)
				sleep(0.7)
				@browser.send_keys :control, :end
				
				
				@browser.ps(:class => "graf graf--p graf--leading graf--trailing").each do |resp|
					Response.create(
						article_id: article.id,
						responseContent: resp.text
						)
				end	
				@browser.back
			end		
			
			
			@browser.back
			@browser.cookies.clear



			count = count+1
			last_inserted = last_inserted + 1

			Sess.find_by_variable("count").update_attribute(:value, count.to_s)
			Sess.find_by_variable("last_inserted").update_attribute(:value, last_inserted.to_s)

		end
	end
end
