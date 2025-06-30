class PagesController < ApplicationController
  def home
    @total_users = User.count
    @recent_users = User.order(created_at: :desc).limit(5)
  end
  
  def about
    @team_members = [
      { name: "Alice Johnson", role: "Lead Developer", bio: "Full-stack developer with 8 years of experience." },
      { name: "Bob Smith", role: "UX Designer", bio: "Passionate about creating intuitive user experiences." },
      { name: "Carol Davis", role: "Product Manager", bio: "Focused on delivering value to users." }
    ]
  end
  
  def contact
    @contact_info = {
      email: "contact@example.com",
      phone: "+1 (555) 123-4567",
      address: "123 Main Street, Anytown, USA"
    }
  end
end 