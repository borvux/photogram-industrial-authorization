desc "Fill the database tables with some sample data"
task sample_data: :environment do
  starting = Time.now

  FollowRequest.delete_all
  Comment.delete_all
  Like.delete_all
  Photo.delete_all
  User.delete_all

  people = [
    { first_name: "Alice", last_name: "Smith" },
    { first_name: "Bob", last_name: "Smith" },
    { first_name: "Carol", last_name: "Smith" },
    { first_name: "Dave", last_name: "Smith" },
    { first_name: "Eve", last_name: "Smith" },
    { first_name: "Frank", last_name: "Wilson" },
    { first_name: "Grace", last_name: "Brown" },
    { first_name: "Henry", last_name: "Davis" },
    { first_name: "Ivy", last_name: "Miller" },
    { first_name: "Jack", last_name: "Anderson" }
  ]

  people.each do |person|
    username = person.fetch(:first_name).downcase

    user = User.create(
      email: "#{username}@example.com",
      password: "password",
      username: username.downcase,
      name: "#{person[:first_name]} #{person[:last_name]}",
      bio: "#{person[:first_name]} is a sample user.",
      website: "https://#{username}.example.com",
      private: person[:first_name].in?([ "Bob", "Carol", "Eve", "Ivy" ]),
      avatar_image: "https://robohash.org/#{username}"
    )
  end

  users = User.all

  users.each do |first_user|
    users.each do |second_user|
      next if first_user == second_user

      if first_user.username.in?([ "alice", "bob", "carol", "dave" ])
        first_user.sent_follow_requests.create(
          recipient: second_user,
          status: "accepted"
        )
      end

      if second_user.username.in?([ "eve", "frank", "grace" ])
        second_user.sent_follow_requests.create(
          recipient: first_user,
          status: "pending"
        )
      end
    end
  end

  users.each do |user|
    3.times do |i|
      # This allows the image to display whether in a codespace, deployed, or local environment
      image_url = if ENV.fetch("CODESPACE_NAME", nil).present?
        "https://#{ENV.fetch("CODESPACE_NAME")}-3000.app.github.dev/#{rand(1..10)}.jpeg"
      elsif ENV.fetch("APPLICATION_HOST", nil).present?
        "https://#{ENV.fetch("APPLICATION_HOST")}/#{rand(1..10)}.jpeg"
      else
        "http://localhost:3000/#{rand(1..10)}.jpeg"
      end

      photo = user.own_photos.create(
        caption: "Sample photo #{i + 1} by #{user.name}",
        image: image_url
      )

      user.followers.each do |follower|
        if follower.username.in?([ "alice", "bob", "eve", "frank" ])
          photo.fans << follower
        end

        if follower.username.in?([ "carol", "dave", "grace" ])
          photo.comments.create(
            body: "Great photo, #{user.name}! ##{i + 1}",
            author: follower
          )
        end
      end
    end
  end

  ending = Time.now
  p "It took #{(ending - starting).to_i} seconds to create sample data."
  p "There are now #{User.count} users."
  p "There are now #{FollowRequest.count} follow requests."
  p "There are now #{Photo.count} photos."
  p "There are now #{Like.count} likes."
  p "There are now #{Comment.count} comments."
end
