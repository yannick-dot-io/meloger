namespace :import do
  desc "Se loger import"
  task se_loger: :environment do
    ImportHousesJob.perform_later
  end
end
