# Flashcard Images

[![CI](https://github.com/jhunschejones/Flashcard-Images/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/jhunschejones/Flashcard-Images/actions/workflows/ci.yml)

## Overview

During the process of creating language learning flashcards for my Japanese studies, I discovered I was spending a large portion of my time searching for pneumonic images. In order to trick my brain a bit and speed up the process, I put together this simple image search UI that queries a handful of image providers, including Pixabay, Unsplash, Pexels, Flickr, and Shutterstock. The search endpoints are secured so that someone else can't blow through my hourly API request allotment, but other than that this is basically as straight forward as it gets.

It turns out the secret to moving quickly for me is removing as many decisions from the process as possible. Now, once I have decided I need an image I simply enter the term in the Flashcard Images app and it gives me a small collection of high-quality images that match my term. There are no "next page" buttons or "more like this" modals, just straight-forward, one-dimensional image results.

So far, this tool alone has helped shave a considerable amount of time off of my flashcard creation process every day. I plan to continue to look for more opportunities like this to simplify and decrease decision overhead in my learning workflow.

## Views

Select which search provider to use:

![Screenshot of search provider selection](docs/screenshots/search%20providers.png)

Search for an image by keyword or phrase:

![Screenshot of search view](docs/screenshots/search.png)

## Setup
Interested in using or modifying this app for your own image search needs? Here's how to get up and running after cloning this repo:
1. `bundle install`
2. Gather API keys and secrets from the providers you wish to use. Make sure to modify the code to remove any providers you do not wish to use from the [search action](https://github.com/jhunschejones/Flashcard-Images/blob/308046250c18acc10ab90aadf838276820cd8dac/app/controllers/image_search_controller.rb#L21-L41):
   - `UNSPLASH_ACCESS_KEY`
   - `UNSPLASH_SECRET_KEY`
   - `PIXABAY_API_KEY`
   - `PEXELS_API_KEY`
   - `FLICKR_API_KEY`
   - `FLICKR_SHARED_SECRET`
   - `FLICKR_ACCESS_TOKEN`
   - `FLICKR_ACCESS_SECRET`
   - `SHUTTERSTOCK_TOKEN`
3. Set the env vars for [Lockbox](https://github.com/ankane/lockbox) and [Blind Index](https://github.com/ankane/blind_index) by following their respective setup instructions.
4. `bundle exec rails db:create db:migrate`
5. Create your user in the Rails console
```ruby
User.create!(name: "Carl Fox", email: "carl@dafox.com", password: "************", password_confirmation: "************")
```
6. If your environment variables are saved in `./tmp/.env`, you should now be able to start a local development server with `./bin/start` or run the test suite with `./bin/test` 
