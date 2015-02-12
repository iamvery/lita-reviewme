# lita-reviewme

A [lita](https://www.lita.io/) handler that helps with [code review](http://en.wikipedia.org/wiki/Code_review)
without getting in the way.

## Installation

Add lita-reviewme to your Lita instance's Gemfile:

``` ruby
gem "lita-reviewme", github: "iamvery/lita-reviewme"
```

## Configuration

Environment variable needed for Github integration:

```
ENV["GITHUB_WOLFBRAIN_ACCESS_TOKEN"]
```

## Usage

### See who is in the review rotation.

> **Jay H.** Nerdbot: reviewers
>
> **Nerdbot** @iamvery, @zacstewart, ...

### Add a name to the review rotation

> **Jay H.** Nerdbot: add @kyfast to reviews
>
> **Nerdbot** added @kyfast to reviews

### Remove a name from the review rotation

> **Jay H.** Nerdbot: remove @kyfast from reviews
>
> **Nerdbot** removed @kyfast from reviews

### Fetch the next reviewer

> **Jay H.** Nerdbot: review me
>
> **Nerdbot** @iamvery

### Post a comment on a Github pull request or issue mentioning the next reviewer

> **Jay H.** Nerdbot: review https://github.com/iamvery/lita-reviewme/issues/7
>
> **Nerdbot** @iamvery should be on it...

## License

[MIT](http://opensource.org/licenses/MIT)
