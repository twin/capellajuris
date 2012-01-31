# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120131023952) do

  create_table "activities", :force => true do |t|
    t.integer  "year"
    t.text     "bullets"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "general_contents", :force => true do |t|
    t.string   "title"
    t.text     "photo"
    t.text     "text"
    t.datetime "updated_at"
  end

  create_table "members", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "voice"
    t.datetime "created_at"
  end

  create_table "news", :force => true do |t|
    t.string "title"
    t.text   "text"
    t.text   "photo"
    t.date   "created_at"
  end

  create_table "sidebars", :force => true do |t|
    t.string   "video_title"
    t.text     "video"
    t.string   "audio_title"
    t.text     "audio_mp3"
    t.text     "audio_ogg"
    t.datetime "updated_at"
  end

  create_table "videos", :force => true do |t|
    t.string   "title"
    t.text     "link"
    t.datetime "created_at"
  end

end
