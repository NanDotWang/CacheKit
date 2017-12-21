# CacheKit

This is a homemade Cache framework. It can cache any **Codable** object, support both value type and reference type.

## Features
- [x] **Memory cache**: Use NSCache as memory cache.
- [x] **Disk cache**: Thread safe, async disk cache.
- [x] **Generic**: Support for fetching and caching any **Codable**.
- [x] **Support value types**: Support caching of value types.
- [x] **UIImageView & UITableViewCell extensions**: Provide ready-to-use extesions for downloading and caching remote images.

## Usage

- **Option 1**: Use it on any `UIImageView`

```swift
let imageView = UIImageView(frame: image_view_frame)
imageView.setImage(with: image_url)
```
- **Option 2**: Use it on `UITableViewCell`

Due to the fact that default `imageView` is managed by `UITableViewCell`, ```cell.setNeedsLayout``` needs to be called to make cell gets updated when retrieving image task finishes, so a convenient extension is added to `UITableViewCell` to make it easy for this specific usage.

You can just use it in `tableView: cellForRowAt indexPath` delegate:

```swift
cell.setImage(with: image_url)
```

- Both extensions can be used with a placeholder image:

```swift
let placeholder = UIImage(named: "placeholder_image")
xxx.setImage(with: url, placeholder: placeholder)
```

- With options:

```swift
// Image cache & process options
let options: [Option] = [.cacheInMemoryOnly, .forceRefresh]

cell.setImage(with: url, placeholder: placeholder, options: options)
```

- Available options:

    * `cacheInMemoryOnly`: Only cache object in memory, not in disk.
    * `forceRefresh`: Force downloading the target from remote resouce, local cache ignored.

- In addition, if you need more control on each image downloading task associated with `UITableViewCell` or `UIImageView`, you can cancel, suspend and resume associated image downloading task at proper time.

```swift
/// Suspend unfinished image downloading task when the cell is disappearing.
func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.suspendImageDownloading()
}
/// Resume unfinished image downloading task when the cell is appearing.
func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.resumeImageDownloading()
}
```

- `Cache` can also be used separately for caching any other `reference` or `value` type object, as long as it confirms to `Codable` protocol

## Example

<img width="320" src="https://github.com/NanDotWang/CacheKit/blob/master/Example/example.gif" />

## Todo list
- [ ] **Memory eviction**: Implement memory evictions upon memory warning notifications.
- [ ] **Disk eviction**: Implement expirations for disk cache.
