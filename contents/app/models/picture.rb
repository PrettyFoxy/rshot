class Picture < ActiveRecord::Base
  belongs_to :album
  belongs_to :profile

  acts_as_taggable_on :tags
  acts_as_commentable

  # Paperclip attachment
  has_attached_file :photo,
    :styles => {
      :thumb   => ["75x75#", :jpg],
      :small   => ["250x250>", :jpg],
      :medium  => ["640x640>", :jpg] },
    :convert_options => { :all => '-auto-orient' }

  # validation
  validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than => 10.megabytes

  # scopes
  scope :same_album, lambda { |att| where("album_id = ?", att) }
  scope :next,       lambda { |att| where("id > ?", att).limit(1).order("id") }
  scope :previous,   lambda { |att| where("id < ?", att).limit(1).order("id DESC") }

  scope :by_profile, lambda { |att| where("profile_id = ?", att) }
  scope :by_album,   lambda { |att| where("album_id = ?", att) }

  def album_name
    unless album.nil?
      album.title
    end
  end

  def self.random
    offset = rand(self.count)
    rand_record = self.first(:offset => offset)
  end

  def gps
    begin
      imgexif = EXIFR::JPEG.new(photo.path)
    rescue EXIFR::MalformedJPEG
      return nil
    end
    #imgexif.gps if imgexif.gps?
    #[imgexif.gps_latitude, imgexif.gps_longitude]

    # https://github.com/picuous/exifr/blob/master/lib/jpeg.rb
    if imgexif.nil? or !imgexif.exif? or imgexif.gps_latitude.nil? or imgexif.gps_latitude.length < 2 or imgexif.gps_longitude.nil? or imgexif.gps_longitude.length < 2
      nil
    else
      lat = imgexif.gps_latitude[0].to_f+imgexif.gps_latitude[1].to_f/60+imgexif.gps_latitude[2].to_f/3600
      lon = imgexif.gps_longitude[0].to_f+imgexif.gps_longitude[1].to_f/60+imgexif.gps_longitude[2].to_f/3600
      [lat, lon]
    end
  end

  def exifdetails
    exifdata = {}

    begin
      imgexif = EXIFR::JPEG.new(photo.path)
    rescue EXIFR::MalformedJPEG
      return exifdata
    end

    if imgexif.exif?
        if imgexif.model.include? imgexif.make
          exifdata[:model] = imgexif.model
        else
          exifdata[:model] = imgexif.make + " " + imgexif.model
        end

        exifdata[:date_time_original] = imgexif.date_time_original
        exifdata[:date_time_digitized] = imgexif.date_time_digitized
        exifdata[:date_time] = imgexif.date_time
        exifdata[:exposure_time] = imgexif.exposure_time.to_s
        exifdata[:focal_length] = imgexif.focal_length.to_i
        exifdata[:focal_length_in_35mm_film] = imgexif.focal_length_in_35mm_film.to_i
        exifdata[:aperture] = imgexif.f_number.to_f
        exifdata[:iso] = imgexif.iso_speed_ratings
        exifdata[:exposure_bias_value] = imgexif.exposure_bias_value.to_f
        exifdata[:white_balance] = imgexif.white_balance
        exifdata[:exposure_program] = imgexif.exposure_program
        exifdata[:flash] = imgexif.flash
        exifdata[:width] = imgexif.width
        exifdata[:height] = imgexif.height
        exifdata[:software] = imgexif.software
        exifdata[:exposure_mode] = imgexif.exposure_mode
        exifdata[:metering_mode] = imgexif.metering_mode
        exifdata[:orientation] = imgexif.orientation
        exifdata[:artist] = imgexif.artist
        exifdata[:copyright] = imgexif.copyright
        exifdata[:brightness_value] = imgexif.brightness_value
        exifdata[:exposure_bias_value] = imgexif.exposure_bias_value
        exifdata[:max_aperture_value] = imgexif.max_aperture_value
        exifdata[:subject_distance] = imgexif.subject_distance
        exifdata[:light_source] = imgexif.light_source
        exifdata[:flash_energy] = imgexif.flash_energy

        exifdata[:exif] = imgexif.exif # debug
    end

    exifdata
  end
end
