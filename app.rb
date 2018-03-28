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
	p array
	p array.class
	p array.length
	# p "#{namearray}"

	redirect "/results?first_name="+ first_name
end
get '/results' do
	first_name = params[:first_name]
	erb :page_3_results, locals:{first_name: first_name, namearray: session[:namearray]}
end
post '/checkname' do
  first_name = params[:first_name]
	session[:pairs] = params[:teams]
	p "this should be the pairs #{session[:pairs]}"
	leftovers = []
 		session[:namearray].each do |pairs|
			session[:pairs].each do |team|
				p "this is #{pairs}"
				p "this is class #{pairs.class}"
				p "this is team #{team}"
				p "this is team class #{team.class}"
				p "this is pairs joing #{pairs.join}"
			if pairs.join(',') == team
				leftovers << team

				end
			end
		end

	session[:leftovers] = leftovers
	redirect "/finalresults?first_name"+ first_name

end
get "/finalresults" do
	first_name = params[:first_name]
 erb :page_4_finalresult, locals:{first_name: first_name, pairs: session[:pairs]}
end
