//
//  ContentView.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var brewData = BrewDataStorage()
    @StateObject var selectedPackageInfo = SelectedPackageInfo()
    @StateObject var updateProgressTracker = UpdateProgressTracker()
    
    @State private var multiSelection = Set<UUID>()
    
    @State private var isShowingInstallSheet: Bool = false
    @State private var isShowingAlert: Bool = false
    
    var body: some View {
        VStack {
            NavigationView {
                List(selection: $multiSelection) {
                    Section(header: Text("Installed Formulae").font(.headline).foregroundColor(.black)) {
                        if brewData.installedFormulae.count != 0 {
                            ForEach(brewData.installedFormulae) { package in
                                
                                NavigationLink {
                                    PackageDetailView(package: package, isCask: false, packageInfo: selectedPackageInfo)
                                } label: {
                                    PackageListItem(packageItem: package)
                                }
                                
                            }
                        } else {
                            ProgressView()
                        }
                    }
                    .collapsible(true)
                    
                    Section(header: Text("Installed Casks").font(.headline).foregroundColor(.black)) {
                        if brewData.installedCasks.count != 0 {
                            ForEach(brewData.installedCasks) { package in
                                
                                NavigationLink {
                                    PackageDetailView(package: package, isCask: true, packageInfo: selectedPackageInfo)
                                } label: {
                                    PackageListItem(packageItem: package)
                                }
                                
                            }
                        } else {
                            ProgressView()
                        }
                    }
                    .collapsible(true)
                }
                .listStyle(.bordered)
            }
            .navigationTitle("Cork")
            .navigationSubtitle("\(brewData.installedCasks.count + brewData.installedFormulae.count) packages installed")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        print("Clicked on upgrade")
                        
                        upgradeBrewPackages(updateProgressTracker)
                    } label: {
                        Label {
                            Text("Upgrade Formulae")
                        } icon: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
        
                ToolbarItemGroup(placement: .destructiveAction) {
                    if !multiSelection.isEmpty { // If the user selected a package, show a button to uninstall it
                        Button {
                            print("Clicked Delete")
                            isShowingAlert.toggle()
                        } label: {
                            Label {
                                Text("Remove Formula")
                            } icon: {
                                Image(systemName: "trash")
                            }
                        }
                        .alert("Are you sure you want to delete the selected package(s)?", isPresented: $isShowingAlert) {
                            Button("Delete", role: .destructive) {
                                
                            }
                            Button("Cancel", role: .cancel) {
                                isShowingAlert.toggle()
                            }
                        } message: {
                            Text("Deleting a formula will completely remove it from your Mac. You will have to reinstall the formula if you want to use it again.")
                            Text("This action cannot be undone.")
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        isShowingInstallSheet.toggle()
                    } label: {
                        Label {
                            Text("Add Formula")
                        } icon: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .padding()
        .environmentObject(brewData)
        .onAppear {
            Task { // Task that gets the contents of the Cellar folder
                print("Started Cellar task at \(Date())")
                let contentsOfCellarFolder = await getContentsOfFolder(targetFolder: AppConstantsLocal.brewCellarPath)
                
                for package in contentsOfCellarFolder {
                    brewData.installedFormulae.append(package)
                    // print("Appended \(package)")
                }
                
                //print(brewData.installedFormulae!)
            }
            
            Task { // Task that gets the contents of the Cask folder
                print("Started Cask task at \(Date())")
                let contentsOfCaskFolder = await getContentsOfFolder(targetFolder: AppConstantsLocal.brewCaskPath)
                
                for package in contentsOfCaskFolder {
                    brewData.installedCasks.append(package)
                    // print("Appended \(package)")
                }
                
                //print(brewData.installedCasks!)
            }
        }
        .sheet(isPresented: $isShowingInstallSheet) {
            AddFormulaView(isShowingSheet: $isShowingInstallSheet)
        }
        .sheet(isPresented: $updateProgressTracker.showUpdateSheet) {
            VStack {
                ProgressView(value: updateProgressTracker.updateProgress)
                    .frame(width: 200)
                Text(updateProgressTracker.updateStage.rawValue)
            }
            .padding()
        }
    }
}
