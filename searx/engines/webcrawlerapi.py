engines:
  - name: webcrawlerapi
    engine: webcrawlerapi
    api_key: !env WEBCRAWLERAPI_KEY
    categories: general
    timeout: 5.0
    disabled: false

  - name: webcrawlerapi-images
    engine: webcrawlerapi_images
    api_key: !env WEBCRAWLERAPI_KEY
    categories: images
    timeout: 5.0
    disabled: false
