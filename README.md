# Tetris.ls
A quick-and-dirty Tetris clone written in a day to learn [LiveScript], a fork of CoffeeScript.

Play it on [my portfolio site].

[my portfolio site]: http://peterjeliot.com/tetris
[LiveScript]: http://livescript.net

#### What it is
* Super short — only 142 lines!

#### What it isn't
* Object-oriented
* Fully-featured (you can't technically win or lose; restarting consists of reloading the page)
* Super clean (adding the prediction took some hacks; OOP would be the right way to go)

#### Running it yourself

Because this is in LiveScript, it must be compiled to JavaScript. I use rails, so here are rails-specific instructions.

Add tetris.ls to your `app/assets/javascripts` folder.

Add this to your Gemfile:

    gem 'livescript-rails'

Add this to any HTML page:

    <div class="tetris">
      <canvas width="200" height="360"></canvas>
    </div>
