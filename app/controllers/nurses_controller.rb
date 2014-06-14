class NursesController < ApplicationController

	def list
		@nurses = Nurse.all
	end

	def new
	end

	def create
		first_name = params[:first_name]
    last_name = params[:last_name]
		gender = params[:gender]
    grade = params[:grade]
=begin
    Nurse.create(:first_name =>first_name,
						 :last_name =>last_name,
						 :gender => gender, 
						 :grade => grade )
=end
    render :text => true and return
	end

	def update_details
		nurse_id = params[:nurse_id]
		@nurse = Nurse.find(nurse_id)
	end

	def create_updated_details
		first_name = params[:first_name]
        last_name = params[:last_name]
		gender = params[:gender]
        grade = params[:grade]
		nurse_id = params[:nurse_id]
		nurse = Nurse.find(nurse_id)
		nurse.first_name = first_name
		nurse.last_name = last_name
		nurse.gender = gender
		nurse.grade = grade
		 if (nurse.save)
			redirect_to :action => "list"
		 end
	end

  def display_all
		nurses = Nurse.all
    nurse_hash = {}
    nurses.each do |nurse|
      id = nurse.id
      nurse_hash[id] = {}
      nurse_hash[id]["first_name"] = nurse.first_name
      nurse_hash[id]["last_name"] = nurse.last_name
      nurse_hash[id]["gender"] = nurse.gender
      nurse_hash[id]["grade"] = nurse.grade
      nurse_hash[id]["date_created"] = nurse.created_at.to_date
    end
    render :json => nurse_hash and return
	end

end
