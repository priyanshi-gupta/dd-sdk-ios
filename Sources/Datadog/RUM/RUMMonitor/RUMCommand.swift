/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Foundation

/// Command processed through the tree of `RUMScopes`.
internal protocol RUMCommand {
    /// The time of command issue.
    var time: Date { get }
    /// Attributes associated with the command.
    var attributes: [AttributeKey: AttributeValue] { get }
}

// MARK: - RUM View related commands

internal struct RUMStartViewCommand: RUMCommand {
    let time: Date
    let attributes: [AttributeKey: AttributeValue]

    /// The object (typically `UIViewController`) identifying the RUM View.
    let identity: AnyObject

    /// Used to indicate if this command starts the very first View in the app.
    /// * default `false` means _it's not yet known_,
    /// * it can be set to `true` by the `RUMApplicationScope` which tracks this state.
    var isInitialView = false
}

internal struct RUMStopViewCommand: RUMCommand {
    let time: Date
    let attributes: [AttributeKey: AttributeValue]

    /// The object (typically `UIViewController`) identifying the RUM View.
    let identity: AnyObject
}

internal struct RUMAddCurrentViewErrorCommand: RUMCommand {
    let time: Date
    let attributes: [AttributeKey: AttributeValue]

    /// The error message.
    let message: String
    /// The error object.
    let error: Error?
}

// MARK: - RUM Resource related commands

internal struct RUMStartResourceCommand: RUMCommand {
    let time: Date
    let attributes: [AttributeKey: AttributeValue]

    /// The name identifying the RUM Resource.
    let name: String
}

internal struct RUMStopResourceCommand: RUMCommand {
    let time: Date
    let attributes: [AttributeKey: AttributeValue]

    /// The name identifying the RUM Resource.
    let name: String
}

internal struct RUMStopResourceWithErrorCommand: RUMCommand {
    let time: Date
    let attributes: [AttributeKey: AttributeValue]

    /// The name identifying the RUM Resource.
    let name: String
    /// The error object.
    let error: Error
}

// MARK: - RUM User Action related commands

internal struct RUMStartUserActionCommand: RUMCommand {
    let time: Date
    let attributes: [AttributeKey: AttributeValue]

    /// The action identifying the RUM User Action.
    let action: RUMUserAction
}

internal struct RUMStopUserActionCommand: RUMCommand {
    let time: Date
    let attributes: [AttributeKey: AttributeValue]

    /// The action identifying the RUM User Action.
    let action: RUMUserAction
}

internal struct RUMAddUserActionCommand: RUMCommand {
    let time: Date
    let attributes: [AttributeKey: AttributeValue]

    /// The action identifying the RUM User Action.
    let action: RUMUserAction
}