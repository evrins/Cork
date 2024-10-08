//
//  Pin an Unpit Package.swift
//  Cork
//
//  Created by David Bureš on 07.03.2023.
//

import Foundation
import CorkShared

func pinAndUnpinPackage(package: BrewPackage, pinned: Bool) async
{
    if pinned
    {
        let pinResult: TerminalOutput = await shell(AppConstants.brewExecutablePath, ["pin", package.name])

        if !pinResult.standardError.isEmpty
        {
            AppConstants.logger.error("Error pinning: \(pinResult.standardError, privacy: .public)")
        }
    }
    else
    {
        let unpinResult: TerminalOutput = await shell(AppConstants.brewExecutablePath, ["unpin", package.name])
        if !unpinResult.standardError.isEmpty
        {
            AppConstants.logger.error("Error unpinning: \(unpinResult.standardError, privacy: .public)")
        }
    }
}
