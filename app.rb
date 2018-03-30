require "sinatra"
enable :sessions


def annas_pairing_app(name_array)
		# name_array = []
		name_pairs = name_array.shuffle
	array_of_names_to_pair = name_array.shuffle.each_slice(2).to_a
	if name_pairs.length % 2 == 1
		array_of_names_to_pair[-2].push(array_of_names_to_pair.pop.join)
		array_of_names_to_pair
	else

		return array_of_names_to_pair
	end
	return array_of_names_to_pair
end



get "/" do
	erb :page_1
end

post "/first_name" do
  first_name = params[:first_name]
  "first name here #{first_name}"
  redirect "/getrandomnames?first_name="+ first_name
end

get "/getrandomnames" do
  first_name = params[:first_name]
  "first name here #{first_name}"
	erb :page_2_get_random_names, locals:{first_name: first_name}
end

post '/getrandomnames' do
	first_name = params[:first_name]
  name1 = params[:name1]
	name2 = params[:name2]
	name3 = params[:name3]
	name4 = params[:name4]
	name5 = params[:name5]
	name6 = params[:name6]
	array = [name1,name2,name3,name4,name5,name6]
	"your names are #{name1}, #{name2}, #{name3}, #{name4}, #{name5}, #{name6}"
	session[:namearray] = annas_pairing_app(array)
	session[:likedpairs] = []
	# p array
	# p array.class
	# p array.length
	# p "#{namearray}"

	redirect "/results?first_name="+ first_name
end

get '/results' do
	first_name = params[:first_name]
	erb :page_3_results, locals:{first_name: first_name}
end

post '/checkname' do
  first_name = params[:first_name]
	session[:pairs] = params[:teams]
 	p "this should be the picked pairs #{session[:pairs]}"

#notes from aarons's instruction from group project: If you remember from today, we had to .join(',') each element in the array so the formatting of the array was the same.
#This little routine does that permanently
#It iterates through session[:namearray] and .joins each element, pushes those elements into a temporary array,
#and then makes session[:namearray] equal to the temporary array...essentially "joining" each element in sessioin[:namearray]
	# p "this should be the pairs #{session[:pairs]}"
	temp_array = []
 		session[:namearray].each do |name|
			temp_array.push(name.join(','))
	end
	session[:namearray] = temp_array

	# aaron notes again: This section is from today.
#  If you remember the first try we had at this, our logic was saying the following:
# 'if pairs(from the session[:namearray]) and team(which was from session[:pairs] array) are equal...do nothing, OTHERWISE, push pairs into the leftovers array'
#  However, as you may remember, it produces duplicated pairs in the leftover array.
#This is due to the first condition we are setting...where we are saying 'if pairs == team, do nothing'.
#This is essentially like saying, 'if pairs is NOT equal to team...do SOMETHING...'
#Think of it this way..., "If person 1 and person 2 are twins(in other words...equal) then do NOTHING,
#OTHERWISE put their picture on the wall.  The result would be a wall full of non-twin couples.
#This would be the same as saying, "If person 1 and person 2 are NOT twins(in other words...NOT equal)
# then put their picture of the wall.  Same result...a wall full of picture of non-twiin couples.

# Sooooo, if we had a list #1-(Aaron, Scott) and compared it with another list #2-(Aaron, Scott, Anna, Gail, Gabby, Rob)
# and we said, "if 'Aaron' from list #1 is equal to each name in list #2 the do NOTHING...OTHERWISE, put that name from list #2 on a NEW list...
#that new list would contain (Scott, Anna, Gail, Gabby, Rob) because these are the names that do NOT equal 'Aaron'.
#Then, if we do the same for the second name on list #1(Scott), the NEW list would then be (Scott, Anna, Gail, Gabby, Rob, Aaron, Anna, Gail, Gabby, Rob)
#This is the duplication pattern we were experiencing today with our pairs...this is a problem!

##One solution (which we hit upon pretty early in the process) is to determine if a pair is from session[:array] is present in sessioin[:pairs]
# If it is, that pair should not be included in the leftovers list.  However, if that pair is NOT present, we should push it into the leftovers array.
#The following code accomplishes that task.  It iterates through session[:namearray] and checks if those pairs are "included" in the session[:pairs} array.
#  If this method is false, "pairs" is pushied into the leftovers array.

#This solution works perfectly.  However, when we tried it today, we were having trouble with the formatting of the arrays.
#The formatting of session[:namearray] and session[:pairs] was just a little different, which caused them not to match when we compared them.

			leftovers = []
			session[:namearray].each do |pairs|
				if session[:pairs].include?(pairs) == false
					leftovers << pairs.split(',')
				else
					session[:likedpairs] <<pairs.split(',')
				end
			end
	puts "this is #{leftovers}
	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	session[:leftovers] = leftovers.flatten
	if session[:leftovers].length == 0
	redirect "/finalresults?first_name="+ first_name
	else
		session[:namearray] = annas_pairing_app(session[:leftovers])
		redirect "/results"
	end

end
# aaron notes continued The next steps (That we discussed today) would be as follows:
# 1) Delete the pairs in the session[:leftovers] array from session[:namearray] (Those pairs need to be removed from the "good" pairs list in session[:pairs] array so we can add newly shuffled pairs later)
# 2) Transform the session[:leftovers] array to be a one dimensional array of names that can be sent to the shuffle/pairing function we originally created.
#      This might be a tricky step due to the formatting of the names in the array.
# 3) Add those newly shuffled and paired pairs back into the session[:namearray] to be displayed on a final erb page.
# 4) Have a party!!!!
get "/finalresults" do
	first_name = params[:first_name]
 erb :page_4_finalresult, locals:{first_name: first_name, pairs: session[:likedpairs]}
end

post '/startover' do
	redirect '/'
end
