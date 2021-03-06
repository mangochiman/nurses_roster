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

    Nurse.create(
                  :first_name =>first_name,
                  :last_name =>last_name,
                  :gender => gender,
                  :grade => grade
                )

    render :text => true and return
	end

	def update_details
		nurse_id = params[:nurse_id]
		@nurse = Nurse.find(nurse_id)
	end

	def create_updated_details

      first_name = params[:first_name]
      last_name = params[:last_name]
      nurse_id = params[:nurse_id]

      nurse = Nurse.find(nurse_id)
      nurse.first_name = first_name unless first_name.blank?
      nurse.last_name = last_name unless last_name.blank?
      nurse.save!
      render :text => true and return

	end

  def display_all
		nurses = Nurse.all
    nurse_hash = {}
    nurses.each do |nurse|
      id = nurse.id
      nurse_hash[id] = {}
      nurse_hash[id]["first_name"] = nurse.first_name.capitalize
      nurse_hash[id]["last_name"] = nurse.last_name.capitalize
      nurse_hash[id]["gender"] = nurse.gender.capitalize
      nurse_hash[id]["grade"] = nurse.grade
      nurse_hash[id]["date_created"] = nurse.created_at.to_date.strftime("%d/%b/%Y")
    end
    render :json => nurse_hash and return
	end

    def search_nurses
      value = params[:value]
      #last_name = value.split(/\W+/)[1] rescue nil
      nurses = Nurse.all(:conditions => ["first_name LIKE (?)", "%" + value + "%"])
      nurse_hash = {}
      nurses.each do |nurse|
        id = nurse.id
        nurse_hash[id] = {}
        nurse_hash[id]["first_name"] = nurse.first_name.capitalize
        nurse_hash[id]["last_name"] = nurse.last_name.capitalize
        nurse_hash[id]["gender"] = nurse.gender.capitalize
        nurse_hash[id]["grade"] = nurse.grade
        nurse_hash[id]["date_created"] = nurse.created_at.to_date.strftime("%d/%b/%Y")
      end
      render :json => nurse_hash and return
    end

    def delete_nurse
      nurse_id = params[:nurse_id]
      Nurse.find(nurse_id).delete
      render :text => true and return
    end
end
