class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :user_id, :user_role, :avatar_url

  def user_role
    object.roles.first.name
  end

  def user_id
    if user_role == "client"
      object.client.id
    elsif user_role == "handyman"
      object.handyman.id
    end
  end
end
