//  Created by Laura Skelton on 3/14/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// A flexible `ListItem` class for configuring views of a specific type with data of a specific type, 
/// using blocks for creation, configuration, and behavior setting. This was designed to be used in 
/// a `ListInterface` to lazily create and configure views as they are recycled in a `UITableView` 
/// or `UICollectionView`.
public class BlockViewConfigurer<ViewType, DataType>: ViewConfigurer where
  ViewType: UIView,
  ViewType: ConfigurableView,
  DataType: Equatable
{
  // MARK: Lifecycle

  /**
   Initializes a `ListItem` that creates and configures a specific type of view for display in a `ListInterface`.

   - Parameters:
    - builder: A closure that builds and returns this view type.
    - configurer: A closure that configures this view type with the specified data type.
    - stateConfigurer: An optional closure that configures this view type for a specific state.
    - behaviorSetter: An optional closure that sets the view's behavior (such as interaction blocks or delegates).
    - data: The data this view takes for configuration, specific to this particular list item instance.
    - dataID: An optional ID to differentiate this row from other rows, used when diffing.
   
   - Returns: A `ListItem` instance that will create the specified view type with this data.
   */
  public init(
    builder: @escaping () -> ViewType = { ViewType() },
    configurer: @escaping (ViewType, DataType, Bool) -> Void,
    stateConfigurer: ((ViewType, DataType, ListCellState) -> Void)? = nil,
    behaviorSetter: ((ViewType, DataType, String?) -> Void)? = nil,
    selectionHandler: ((DataType, String?) -> Void)? = nil,
    data: DataType,
    dataID: String? = nil)
  {
    self.data = data
    self.builder = builder
    self.configurer = configurer
    self.stateConfigurer = stateConfigurer
    self.behaviorSetter = behaviorSetter
    self.selectionHandler = selectionHandler
    self.dataID = dataID
  }

  // MARK: Public

  public let dataID: String?
  public let data: DataType

  public var isSelectable: Bool {
    return selectionHandler != nil
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    if let other = otherDiffableItem as? BlockViewConfigurer<ViewType, DataType> {
      return self.data == other.data
    } else {
      return false
    }
  }

  public func makeView() -> ViewType {
    return builder()
  }

  public func configureView(_ view: ViewType, animated: Bool) {
    configurer(view, data, animated)
  }

  public func configureView(_ view: ViewType, forState state: ListCellState) {
    stateConfigurer?(view, data, state)
  }

  public func setViewBehavior(_ view: ViewType) {
    behaviorSetter?(view, data, dataID)
  }

  public func didSelect() {
    selectionHandler?(data, dataID)
  }

  // MARK: Private

  private let builder: () -> ViewType
  private let configurer: (ViewType, DataType, Bool) -> Void
  private let stateConfigurer: ((ViewType, DataType, ListCellState) -> Void)?
  private let behaviorSetter: ((ViewType, DataType, String?) -> Void)?
  private let selectionHandler: ((DataType, String?) -> Void)?
}