# CacheKit

This is a homemade Cache framework. It can cache any **Codable** object, support both value type and reference type.

## Features
- [x] **Memory cache**: Use NSCache as memory cache.
- [x] **Disk cache**: Thread safe, async disk cache.
- [x] **Generic**: Support for fetching and caching any **Codable**.
- [x] **Support value types**: Support caching of value types.
- [x] **UITableViewCell extension**: Provide a ready-to-use **UITableViewCell** extesion for downloading and caching remote images on table view.

## Usage
- Create a **`CacheProvider`** property for caching **`CodableImage`** in the class
```swift
  private let cacheProvider = CacheProvider<CodableImage>()
```
- Use it in **`tableView: cellForRowAt indexPath`** delegate:
```swift
  cell.setImage(with: url, cacheProvider: cacheProvider)
```
- Use it with a placeholder image:
```swift
  let placeholder = UIImage(named: "placeholder_image")
  cell.setImage(with: url, cacheProvider: cacheProvider, placeholder: placeholder)
```
- Use it with options:
```swift
  let options = [.scaleTo(0.5), .cacheInMemoryOnly]
  cell.setImage(with: url, cacheProvider: cacheProvider, placeholder: placeholder, options: options)
```
- Available options:
  * `cacheInMemoryOnly`: Only cache the object in memory, not in disk.
  * `forceRefresh`: Force downloading the target from remote resouce, local cache ignored.
  * `scaleTo(CGFloat)`: Scale downloaded image according to certain scale factor.
  * `resizeTo(CGSize)`: Resize downloaded image to a specific size.
  
- Suspend & resume image downloading for **UITableViewCell**
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
- **`CacheProvider`** can be used separately for caching any other **reference** or **value** type object, as long as it confirms to **Codable** protocol

## Todo list
- [ ] **Memory eviction**: Implement memory evictions upon memory warning notifications.
- [ ] **Disk eviction**: Implement expirations for disk cache.
