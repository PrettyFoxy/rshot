# encoding: utf-8
#
# rshot (http://rshot.net) - a social digital photo gallery.
# (c) 2011 Raphael Kallensee
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

class ProfilesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]

  # GET /profiles/1
  # GET /profiles/1.xml
  def show
    @profile = Profile.find_by_nick(params[:id])
    @pictures = Picture.find_all_by_profile_id(@profile.id)
    @albums = Album.find_all_by_profile_id(@profile.id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    @profile = Profile.find_by_nick(params[:id])

    if params[:id] != current_user.profile.to_param
      redirect_to url_for(:controller => '/home', :action => 'index') # TODO: throw 403!
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.xml
  def update
    @profile = Profile.find_by_nick(params[:id])

    if params[:id] != current_user.profile.to_param
      redirect_to url_for(:controller => '/home', :action => 'index') # TODO: throw 403!
    end

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to(@profile, :flash => {:success => 'Profile was successfully updated.'}) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end
end
