//
//  RswiftGenerateInternalResources.swift
//  
//
//  Created by Tom Lokhorst on 2022-10-19.
//

import Foundation
import PackagePlugin

@main
struct RswiftGenerateInternalResources: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let target = target as? SourceModuleTarget else { return [] }

        let outputDirectoryPath = context.pluginWorkDirectory
            .appending(subpath: target.name)

        try FileManager.default.createDirectory(atPath: outputDirectoryPath.string, withIntermediateDirectories: true)

        let rswiftPath = outputDirectoryPath.appending(subpath: "R.generated.swift")

        let sourceFiles = target.sourceFiles
            .filter { $0.type == .resource || $0.type == .unknown }
            .map(\.path.string)

        let inputFilesArguments = sourceFiles
            .flatMap { ["--input-files", $0 ] }

        let bundleSource = target.kind == .generic ? "module" : "finder"
        let description = "\(target.kind) module \(target.name)"

        return [
            .buildCommand(
                displayName: "R.swift generate resources for \(description)",
                executable: try context.tool(named: "rswift").path,
                arguments: [
                    "generate", rswiftPath.string,
                    "--input-type", "input-files",
                    "--bundle-source", bundleSource,
                ] + inputFilesArguments,
                outputFiles: [rswiftPath]
            ),
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension RswiftGenerateInternalResources: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {

      guard let target = target as? SourceModuleTarget else { return [] }

      let outputDirectoryPath = context.pluginWorkDirectory
          .appending(subpath: target.name)

      try FileManager.default.createDirectory(atPath: outputDirectoryPath.string, withIntermediateDirectories: true)

      let rswiftPath = outputDirectoryPath.appending(subpath: "R.generated.swift")

      let sourceFiles = target.sourceFiles
          .filter { $0.type == .resource || $0.type == .unknown }
          .map(\.path.string)

      let inputFilesArguments = sourceFiles
          .flatMap { ["--input-files", $0 ] }

      let bundleSource = target.kind == .generic ? "module" : "finder"
      let description = "\(target.kind) module \(target.name)"

      return [
          .buildCommand(
              displayName: "R.swift generate resources for \(description)",
              executable: try context.tool(named: "rswift").path,
              arguments: [
                  "generate", rswiftPath.string,
                  "--input-type", "input-files",
                  "--bundle-source", bundleSource,
              ] + inputFilesArguments,
              outputFiles: [rswiftPath]
          ),
      ]
    }
}

#endif
