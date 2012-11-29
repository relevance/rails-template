after_everything do 
  if prefer(:stack, 'heroku') && prefer(:heroku_deploy, true)
    require 'timeout'
    begin
      Timeout.timeout(5) do
        @pipe = IO.popen("heroku auth:whoami")
        Process.wait @pipe.pid
        @heroku_user = @pipe.read
      end
    rescue Timeout::Error
      @heroku_user = nil
      Process.kill 9, @pipe.pid
      Process.wait @pipe.pid
    end

    if @heroku_user
      %x{heroku create #{prefs[:heroku_app_name]}}
      if prefs[:heroku_app_name]
        %x{heroku git:remote -a #{prefs[:heroku_app_name] }}
        %x{git push heroku master -f}
        %x{heroku pg:reset DATABASE_URL --confirm #{prefs[:heroku_app_name]}}
      else
        %x{git push heroku master}
      end
      %x{heroku run rake db:migrate db:seed}
    else
      puts "Could not create and deploy heroku application because you are not logged in!"
    end
  end
end

__END__

name: finalize
description: "After everything else, do this"
author: RailsApps + Relevance

requires: [heroku]
run_after: [views]
category: deploy
