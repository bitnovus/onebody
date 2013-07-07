class AlbumAuthorizer < ApplicationAuthorizer

  def readable_by?(user)
    # belongs to me
    if resource.owner == user
      true
    # belongs to a friend
    elsif Person === resource.owner and user.friend_ids.include?(resource.owner.id)
      true
    # belongs to a group I'm in
    elsif Group === resource.owner and user.member_of?(resource.owner)
      true
    # is marked public
    elsif resource.is_public?
      true
    elsif user.admin?(:manage_pictures)
      true
    end
  end

  def updatable_by?(user)
    # belongs to me
    if resource.owner == user
      true
    # belongs to a group I'm admin of
    elsif  Group === resource.owner and resource.owner.admin?(user)
      true
    # I'm a global admin
    elsif user.admin?(:manage_pictures)
      true
    end
  end

  alias_method :deletable_by?, :updatable_by?

  def self.readable_by(user, scope=Album.scoped)
    if user.admin?(:manage_pictures)
      scope
    else
      scope.where(
        "(owner_type = 'Person' and owner_id in (?)) or " +
        "(owner_type = 'Group' and owner_id in (?)) or " +
        "is_public = ?",
        [user.id] + user.friend_ids,
        user.group_ids,
        true
      )
    end
  end

end
