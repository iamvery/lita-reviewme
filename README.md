# lita-reviewme
[![Build Status](https://travis-ci.org/iamvery/lita-reviewme.svg?branch=master)](https://travis-ci.org/iamvery/lita-reviewme)

A [lita](https://www.lita.io/) handler that helps with [code review](http://en.wikipedia.org/wiki/Code_review)
without getting in the way.

The handler rotates, in order, through a list of names to provider a "reviewer"
for some unit of work.

## Installation

Add lita-reviewme to your Lita instance's Gemfile:

``` ruby
gem "lita-reviewme", github: "iamvery/lita-reviewme"
```

## Configuration

For the Github integration, you must set an access token in your `lita_config.rb`.
You may use your Github account or create a special account just to leave notification comments.
Regardless the user must have access to the repo being reviewed, and the token must be allowed to leave comments on pull requests.

```
# your bot's lita_config.rb
config.handlers.reviewme.github_access_token = ENV["GITHUB_ACCESS_TOKEN"]
```

The default message that is posted on GitHub pull request is `:eyes: @<reviewer>`.
The message can be customized via `config.handlers.reviewme.github_comment_template`.
If you would like the reviewer to be notified, be sure add `%{reviewer}` to your string.

```
# your bot's lita_config.rb
# Add %{reviewer} for the user to be tagged and notified on GitHub
config.handlers.reviewme.github_comment_template = "Hey %{reviewer}, check it out! :tada:"
```

Additionally, you can assign a lambda if you would like more finite control of what GitHub comments are sent.
Note that `reviewer` and `pull_request` are required arguments.

```
# your bot's lita_config.rb
#
# Note:
# `reviewer` is a username string without the '@'
# `pull_request` is a hash object from GitHub API.

config.handlers.reviewme.github_comment_template = lamda do |reviewer, pull_request|
  title = pull_request[:title]
  "Hey #{reviewer}, check out my new PR called #{title} :tada:"
end
```

Your bot can assign a reviewer by adding a comment to the requested PR (default) or by [requesting a review](https://github.com/blog/2291-introducing-review-requests) (or both).

```
# your bot's lita_config.rb
#
# Note:
# The following configuration will enable review requests and disable comments
config.handlers.reviewme.github_request_review = true  # default (false)
config.handlers.github_comment = false                 # default (true)
```

## Usage

### See who is in the review rotation.

> **Jay H.** Nerdbot: reviewers
>
> **Nerdbot** Responding via private message...
>
> **Nerdbot (privately)** channel-name: iamvery, zacstewart, ...

### Add a name to the review rotation

> **Jay H.** Nerdbot: add kyfast to reviews
>
> **Nerdbot** added kyfast to reviews

### Remove a name from the review rotation

> **Jay H.** Nerdbot: remove kyfast from reviews
>
> **Nerdbot** removed kyfast from reviews

### Fetch the next reviewer

> **Jay H.** Nerdbot: review me
>
> **Nerdbot** iamvery

### Comment on a Github pull request or issue
This will post a comment mentioning the next reviewer on the referenced Github
pull request or issue. In order for this to work, @wolfbrain must have access
to the repository.

> **Jay H.** Nerdbot: review https://github.com/iamvery/lita-reviewme/issues/7
>
> **Nerdbot** iamvery should be on it...

If your Github user is different from your chat user, you might tweak your notification settings to include your Github username.

## License

[MIT](http://opensource.org/licenses/MIT)
