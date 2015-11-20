//
//  AppDelegate.swift
//  OutlineViewTutorial
//
//  Created by Scott on 12/30/14.
//  Copyright (c) 2014 CrankySoft. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate {

	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var treeController: NSTreeController!
	@IBOutlet weak var outlineView: NSOutlineView!

	let dragType : String = "testTreeDragType"
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}
	
	override func awakeFromNib() {
		// Insert code here after it is created
		
		// Register for the dragged type
		outlineView!.registerForDraggedTypes([dragType])
	}

	// MARK: - Core Data stack

	lazy var applicationDocumentsDirectory: NSURL = {
	    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cranysoft.OutlineViewTutorial" in the user's Application Support directory.
	    let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
	    let appSupportURL = urls[urls.count - 1] as NSURL
	    return appSupportURL.URLByAppendingPathComponent("com.crankysoft.OutlineViewTutorial")
	}()

	lazy var managedObjectModel: NSManagedObjectModel = {
	    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
	    let modelURL = NSBundle.mainBundle().URLForResource("OutlineViewTutorial", withExtension: "momd")!
	    return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
	    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
	    let fileManager = NSFileManager.defaultManager()
	    var shouldFail = false
	    var error: NSError? = nil
	    var failureReason = "There was an error creating or loading the application's saved data."

	    // Make sure the application files directory is there
		let propertiesOpt: [NSObject: AnyObject]?
		do {
			propertiesOpt = try self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey])
		} catch var error1 as NSError {
			error = error1
			propertiesOpt = nil
		} catch {
			fatalError()
		}
	    if let properties = propertiesOpt {
	        if !properties[NSURLIsDirectoryKey]!.boolValue {
	            failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
	            shouldFail = true
	        }
	    } else if error!.code == NSFileReadNoSuchFileError {
	        error = nil
	        do {
				try fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil)
			} catch var error1 as NSError {
				error = error1
			} catch {
				fatalError()
			}
	    }
	    
	    // Create the coordinator and store
	    var coordinator: NSPersistentStoreCoordinator?
	    if !shouldFail && (error == nil) {
	        coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
	        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("OutlineViewTutorial.storedata")
	        do {
				try coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: nil)
			} catch var error1 as NSError {
				error = error1
	            coordinator = nil
	        } catch {
				fatalError()
			}
	    }
	    
	    if shouldFail || (error != nil) {
	        // Report any error we got.
	        let dict = NSMutableDictionary()
	        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
	        dict[NSLocalizedFailureReasonErrorKey] = failureReason
	        if error != nil {
	            dict[NSUnderlyingErrorKey] = error
	        }
	        error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: nil)
	        NSApplication.sharedApplication().presentError(error!)
	        return nil
	    } else {
	        return coordinator
	    }
	}()

	lazy var managedObjectContext: NSManagedObjectContext? = {
	    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
	    let coordinator = self.persistentStoreCoordinator
	    if coordinator == nil {
	        return nil
	    }
	    var managedObjectContext = NSManagedObjectContext()
	    managedObjectContext.persistentStoreCoordinator = coordinator
	    return managedObjectContext
	}()

	// MARK: - Core Data Saving and Undo support

	@IBAction func saveAction(sender: AnyObject!) {
	    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
	    if let moc = self.managedObjectContext {
	        if !moc.commitEditing() {
	            NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
	        }
	        var error: NSError? = nil
	        if moc.hasChanges {
				do {
					try moc.save()
				} catch let error1 as NSError {
					error = error1
					NSApplication.sharedApplication().presentError(error!)
				}
			}
	    }
	}

	func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
	    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
	    if let moc = self.managedObjectContext {
	        return moc.undoManager
	    } else {
	        return nil
	    }
	}

	func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
	    // Save changes in the application's managed object context before the application terminates.
	    
	    if let moc = managedObjectContext {
	        if !moc.commitEditing() {
	            NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
	            return .TerminateCancel
	        }
	        
	        if !moc.hasChanges {
	            return .TerminateNow
	        }
	        
	        var error: NSError? = nil
	        do {
				try moc.save()
			} catch let error1 as NSError {
				error = error1
	            // Customize this code block to include application-specific recovery steps.
	            let result = sender.presentError(error!)
	            if (result) {
	                return .TerminateCancel
	            }
	            
	            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
	            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
	            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
	            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
	            let alert = NSAlert()
	            alert.messageText = question
	            alert.informativeText = info
	            alert.addButtonWithTitle(quitButton)
	            alert.addButtonWithTitle(cancelButton)
	            
	            let answer = alert.runModal()
	            if answer == NSAlertFirstButtonReturn {
	                return .TerminateCancel
	            }
	        }
	    }
	    // If we got here, it is time to quit.
	    return .TerminateNow
	}
	
	
	// MARK: - NSOutlineView Data Source Helper Functions
	
	func childrenOfNode(node : AnyObject?) -> NSSet?{
		// 1. If we have a node then return it's children
		// 2. Else we need to locate the root node and try to return it's children
		// 3. Finally we exhaust our choices and return nil
		if node != nil{
			let item : Test! = node as! Test
			let children : NSSet? = item.children
			return children
		}else if let rootTreeNode : NSTreeNode = treeController.arrangedObjects.descendantNodeAtIndexPath(NSIndexPath(index: 0)){
			if let rootNode : Test = rootTreeNode.representedObject as? Test{
				return rootNode.children
			}
		}
		return nil
	}
	
	func rootNode() -> Test?{
		if let rootTreeNode : NSTreeNode = treeController.arrangedObjects.descendantNodeAtIndexPath(NSIndexPath(index: 0)){
			return rootTreeNode.representedObject as? Test
		}else{
			return nil
		}
	}
	
	func isLeaf(item : AnyObject?) -> Bool{
        
		if item != nil{
			if let children = item?.children{
				if children?.count == 0 {
					return true
				}else{
					return false
				}
			}
		}
		// item is nil
		return false
	}
	
	// MARK: - NSOutlineView Data Source Required Functions
	
	// Set the View Cell objects to the data from the TreeItem
	func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
		let identifier : NSString? = tableColumn?.identifier
		var tableCellView : NSTableCellView?
		
		if identifier!.isEqualToString("MainCell"){
			
			// Supply the image and name
			let treeItem : AnyObject? = item.representedObject
			tableCellView = outlineView.makeViewWithIdentifier("MainCell", owner: self) as? NSTableCellView
			
			let imageView : NSImageView! = tableCellView?.valueForKey("imageView") as? NSImageView
			let textField : NSTextField! = tableCellView?.valueForKey("textField") as? NSTextField
            
            
            
			if isLeaf(treeItem){
				imageView.image = NSImage(named: "leaf")
			}else{
				imageView.image = NSImage(named: "folder")
			}
			
			textField.stringValue = treeItem!.name
		}
		
		return tableCellView
	}
	
	// MARK: - NSOutlineView Drag and Drop Required Functions
	
	func outlineView(outlineView: NSOutlineView, writeItems
		items: [AnyObject],
		toPasteboard pasteboard: NSPasteboard) -> Bool {
			
			//get an array of URIs for the selected objects
			let mutableArray : NSMutableArray = NSMutableArray()
			
			for object : AnyObject in items{
				if let treeItem : AnyObject? = object.representedObject!{
					mutableArray.addObject(treeItem!.objectID.URIRepresentation())
				}
			}
			
			let data : NSData = NSKeyedArchiver.archivedDataWithRootObject(mutableArray)
			pasteboard.setData(data, forType: dragType)
			
			return true
	}
	
	func outlineView(outlineView: NSOutlineView, validateDrop
		info: NSDraggingInfo,
		proposedItem item: AnyObject?,
		proposedChildIndex index: Int) -> NSDragOperation {
			return NSDragOperation.Move
	}
	
	func outlineView(outlineView: NSOutlineView, acceptDrop
		info: NSDraggingInfo,
		item: AnyObject?,
		childIndex index: Int) -> Bool {
			
			// Determine the parent node
			var parentItem : AnyObject? = item?.representedObject
			
			// Get Dragged NSTreeNodes
			let pasteboard : NSPasteboard = info.draggingPasteboard()
			let data : NSData = pasteboard.dataForType(dragType)! as NSData
			let draggedArray : NSArray = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSArray
			
			// Loop through DraggedArray
			for object : AnyObject in draggedArray{
				// Get the ID of the NSManagedObject
				if let id : NSManagedObjectID? = persistentStoreCoordinator?.managedObjectIDForURIRepresentation(object as! NSURL){
					// Set new parent to the dragged item
					if let treeItem = managedObjectContext?.objectWithID(id!){
						treeItem.setValue(parentItem, forKey: "parent")
					}
				}
			}
			
			// Reload the OutlineView
			outlineView.reloadData()
			
			return true
	}

}

