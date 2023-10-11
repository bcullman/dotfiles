# Simple dotfile backup script

## Initial Setup
1. clone this repo to your home directory
1. add the files and/or directories you want to backup to the dotfiles-config.json file
1. run the script with `./dotfiles-sync.sh`

This will create a copy of the files you want to backup in the dotfiles src directory.
You can then commit and push the changes to your dotfiles repo.

## Automated git push
Once you are happy with the files in the dotfiles src directory you can run `./dotfiles-sync.sh` in automated mode with the flag `--automated` or `-a` to git push the changes to your dotfiles repo.

## Scheduled backups
From there, you can set up `./dotfiles-sync.sh` as a cron job to run at a regular interval to keep your dotfiles up to date.

To do this run `crontab -e`. Add the following line to the file (run hourly)...

```
0 * * * * /path/to/dotfiles-sync.sh -a
```

...then save and close the file.