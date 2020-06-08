class ArticlesController < ApplicationController



	def new
	end

	# display the last inserted articles
	def index

		@tag = params[:search]
		last_inserted = Sess.find_by_variable("last_inserted").value.to_i
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
		
		Sess.find_by_variable("start_time").update_attribute(:value, "0")
		Sess.find_by_variable("finish_time").update_attribute(:value, "0")
		GetMediumDataJob.perform_later params[:search], "next"
		redirect_to articles_path(search: params[:search])
	end

	# executed when user search's a tag
	def create
		

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
			
		redirect_to articles_path(search: tag)

		end
	end

	
end
