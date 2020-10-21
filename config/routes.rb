Rails.application.routes.draw do
  root to: "image_search#search"

  controller :sessions do
    get "login" => :new
    post "login" => :create
    delete "logout" => :destroy
  end

  controller :image_search do
    get "search" => :search
  end
end
