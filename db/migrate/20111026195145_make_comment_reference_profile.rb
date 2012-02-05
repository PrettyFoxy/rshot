# encoding: utf-8
#
# rshot (http://rshot.net) - a social digital photo gallery.
# (c) 2011-2012 Raphael Kallensee
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class MakeCommentReferenceProfile < ActiveRecord::Migration
  def up
    add_column :comments, :profile_id, :integer, :references => "profiles"
    add_index :comments, :profile_id

    # if migrating from a running version, migrate references.
    Comment.all.each do |comment|
      if comment.respond_to? :user
        comment.profile_id = comment.user.profile.id
        comment.save
      end
    end
  end

  def down
    remove_index :comments, :profile_id
    remove_column :comments, :profile_id
  end
end
