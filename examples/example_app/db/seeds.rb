# Create sample users
users_data = [
  { name: "Alice Johnson", email: "alice@example.com", bio: "Full-stack developer with 8 years of experience in Ruby on Rails and JavaScript." },
  { name: "Bob Smith", email: "bob@example.com", bio: "UX Designer passionate about creating intuitive and beautiful user experiences." },
  { name: "Carol Davis", email: "carol@example.com", bio: "Product Manager focused on delivering value to users through thoughtful product design." },
  { name: "David Wilson", email: "david@example.com", bio: "Backend developer specializing in API design and database optimization." },
  { name: "Eva Brown", email: "eva@example.com", bio: "Frontend developer with expertise in React, Vue.js, and modern CSS." },
  { name: "Frank Miller", email: "frank@example.com", bio: "DevOps engineer with experience in AWS, Docker, and CI/CD pipelines." },
  { name: "Grace Lee", email: "grace@example.com", bio: "QA Engineer dedicated to ensuring software quality and user satisfaction." },
  { name: "Henry Taylor", email: "henry@example.com", bio: "Data Scientist working on machine learning and analytics solutions." }
]

users_data.each do |user_data|
  User.find_or_create_by(email: user_data[:email]) do |user|
    user.name = user_data[:name]
    user.bio = user_data[:bio]
  end
end

puts "Created #{User.count} users" 