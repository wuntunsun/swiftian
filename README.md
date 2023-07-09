# swiftian

Exploring SwitfUI...

## Targeting multiple systems and versions

There are three key tools for handling multiple systems and versions. The first is the use of compiler directives, which have the advantage of configuring at compile time, the second are conditional attributes, which allow for version specific predicates. The last is @Environment which can adapt to use choices on the system e.g. split screen on iPad.

### Compiler directives

Along with the usual #if DEBUG, and any project specific directives, there are 

1. #if targetEnvironment(simulator)
2. #if os(tvOS)
3. #if swift(<5)
4. #if canImport(UIKit)

These can be useful in some cases, in particular projects that are iPhone only as then #if os(iOS), which also includes iPad, can be used.

### Conditional attributes

1. @available
2. if #available(iOS 16, *)

The first can be used where only declarations are allowed.

A common problem that arose with the advent of Xcode 14 was: Stored properties cannot be marked potentially unavailable with '@available', whereby the compiler is making clear that it can not safely do what is being asked of it.

The following would produce the above error:

```
@available(iOS 16, *)
@State private var columnVisibility = NavigationSplitViewVisibility.all
```

I have seen solutions that use a type that is safe across all versions e.g. Any, but that requires unboxing on the latest code. Other solutions wrap these in a new type that uses conditional attributes, and possibly also compiler directives, to distinguish the cases. Wrapping a lot of code in this manner introduces a level of abstraction that gets baked into the code base which is subsequently difficult to remove. My preferred solution is to use a private declaration for the specific case that can be easily refactored once support for earlier systems is removed.

```
@available(iOS 16, *)
private struct NavigationSplitView: View {

	@State private var columnVisibility = NavigationSplitViewVisibility.all

	var body: some View {
    
    	SwiftUI.NavigationSplitView(columnVisibility: $columnVisibility) {
        	...
    	} content: {
        	...
    	} detail: {
        	...
    	}
    	.navigationSplitViewStyle(.balanced)
	}
}
```

It is then used later.

```
var body: some View {
...
	if #available(iOS 16, *) {
    	RootView.NavigationSplitView()
	}
	else {
    	NavigationView {...}
	    .navigationViewStyle(.columns)
	}
}
```


### @Environment

Apple advises that UserInterfaceSizeClass be used to configure the UI rather than UIDevice or similar. This is because the environment changes dependent on the system and user choices made. A rather complex example is using Table where possible; it was introduced in iOS 16 but collapses to the first column in a .compact environment.

See https://developer.apple.com/documentation/swiftui/table

Note that UserInterfaceSizeClass is nil on platforms which are always .regular e.g. iPad and macOS.

```
@Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
@Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
@Environment(\.dynamicTypeSize) var typeSize
```

```
// Nota bene: Robert Norris - horizontalSizeClass == .compact covers all iPhone in portait,
// excludes iPhone Plus in landscape, Both primary and secondary apps on iPad in split screen
// and slide over in portrait, primary app on iPad and iPad mini in landscape, and secondary
// app in all but iPad Pro in landscape. The use of typeSize further scopes the use.
if horizontalSizeClass == .compact || typeSize > .large {
	if #available(iOS 16, *) {
        NavigationStack {...}
    } else {
        NavigationView {...}
        .navigationViewStyle(.stack)
    }
} 
else {
	if #available(iOS 16, *) {
        Table(...) {
    		TableColumn(...) { _ in
        	VStack(alignment: .leading) {
            	if verticalSizeClass == .compact {
                	// Nota bane: Robert Norris - iPhone Plus in landscape; similar to a List.
                	Text(...)
                	Text(...)
            	}
            	else {
                	Text(...)
            	}
        	}
    	}
    	// Nota bene: Robert Norris - subsequent columns will be ignored when verticalSizeClass != .compact
    	// as such they will only display on iPad and macOS.
    	...
    }
    else {
    	...
    }
}
```
