"
Description
--------------------

I am an abstract slot used to declare fame properties for a class.
The declared properties with my subclasses must have an opposite.

A relation slot will have:
- A name which is the name of the property
- A type which is the type of the property 
- An inverse name which is the name of the opposite property.

My sublasses will define everything related to the cardinality of the relation side.
 
Internal Representation and Key Implementation Points.
--------------------

    Instance Variables
	inverseName:		<aString>		The name of the opposite slot.
	inverseSlot:		<aSlot>
	targetClass:		<aClass>

"
Class {
	#name : #FMRelationSlot,
	#superclass : #InstanceVariableSlot,
	#instVars : [
		'targetClass',
		'inverseName',
		'inverseSlotDic'
	],
	#category : #'Fame-Core-Utilities'
}

{ #category : #'instance creation' }
FMRelationSlot class >> named: aSymbol inverse: anInverseSymbol inClass: aTargetClassOrSymbol [ 

	^(super named: aSymbol) inverse: anInverseSymbol inClass: aTargetClassOrSymbol 
]

{ #category : #comparing }
FMRelationSlot >> = anObject [

	^ super = anObject and: [ 
		  self targetClassName = anObject targetClassName and: [ 
			  self inverseName = anObject inverseName ] ]
]

{ #category : #internal }
FMRelationSlot >> addAssociationFrom: ownerObject to: otherObject [

	"A new reference from <ownerObject> to <otherObject> is created. Here we update the other 
	side of the association. If the other side is a ToOne association this means that an other
	association may have to be removed first."

	| realInverseSlot |
	realInverseSlot := self realInverseSlotFor: otherObject.
	realInverseSlot
		reverseAddAssociationFrom: ownerObject
		to: otherObject
]

{ #category : #'code generation' }
FMRelationSlot >> emitStore: aMethodBuilder [
	| tempName |
	tempName := '0slotTempForStackManipulation'.
	aMethodBuilder
		addTemp: tempName;
		storeTemp: tempName;
		popTop;
		pushLiteral: self;
		pushInstVar: index;
		pushTemp: tempName;
		pushReceiver;
		send: #updateOld:new:in:;
		storeInstVar: index
]

{ #category : #'code generation' }
FMRelationSlot >> emitValue: aMethodBuilder [
	aMethodBuilder
		pushLiteralVariable: (AdditionalBinding key: #slot value: self);
		pushReceiver;
		send: #read:
]

{ #category : #testing }
FMRelationSlot >> hasInverse [

	^ self inverseName isNotNil
]

{ #category : #comparing }
FMRelationSlot >> hasSameDefinitionAs: otherSlot [

	^ (super hasSameDefinitionAs: otherSlot) and: [ 
		  self targetClassName = otherSlot targetClassName and: [ 
			  self inverseName = otherSlot inverseName ] ]
]

{ #category : #comparing }
FMRelationSlot >> hash [

	^ (super hash bitXor: self targetClassName hash) bitXor:
		  self inverseName hash
]

{ #category : #initialization }
FMRelationSlot >> inClass: aTargetClassOrSymbol [
	targetClass := aTargetClassOrSymbol
]

{ #category : #initialization }
FMRelationSlot >> initialize [
	super initialize.
	inverseSlotDic := IdentityDictionary new
]

{ #category : #initialization }
FMRelationSlot >> inverse: anInverseSymbol inClass: aTargetClassOrSymbol [
	self inClass: aTargetClassOrSymbol.
	inverseName := anInverseSymbol
]

{ #category : #accessing }
FMRelationSlot >> inverseName [
	^ inverseName
]

{ #category : #testing }
FMRelationSlot >> isAccessedIn: aMethod [
	^ aMethod allLiterals includes: self
]

{ #category : #testing }
FMRelationSlot >> isFMRelationSlot [
	^ true
]

{ #category : #testing }
FMRelationSlot >> isFameSlot [
	^ true
]

{ #category : #testing }
FMRelationSlot >> isReadIn: aMethod [
	^ aMethod allLiterals includes: self
]

{ #category : #testing }
FMRelationSlot >> isToMany [
	^ self isToOne not
]

{ #category : #testing }
FMRelationSlot >> isToOne [
	^ false
]

{ #category : #testing }
FMRelationSlot >> isWrittenIn: aMethod [
	^ aMethod allLiterals includes: self
]

{ #category : #printing }
FMRelationSlot >> printOn: aStream [

	aStream
		store: self name;
		nextPutAll: ' => ';
		nextPutAll: self class name.
	aStream
		nextPutAll: ' type: ';
		store: self targetClassName.
	self hasInverse ifTrue: [ 
		aStream
			nextPutAll: ' opposite: ';
			store: self inverseName ]
]

{ #category : #accessing }
FMRelationSlot >> realInverseSlotFor: anObject [

	^ (inverseSlotDic at: anObject class ifAbsentPut: [ 
		   MessageSend
			   receiver: self
			   selector: #resolveSlotNamed:for:
			   arguments: { 
					   self inverseName.
					   anObject class } ]) value
]

{ #category : #internal }
FMRelationSlot >> removeAssociationFrom: ownerObject to: otherObject [

	"A reference from <ownerObject> to <otherObject> is removed. Here we update the other 
	side of the association. If the other side is a ToOne association set the value to nil,
	for ToMany associations remove <ownerObject> from the collection."

	| realInverseSlot |
	realInverseSlot := self realInverseSlotFor: otherObject.
	realInverseSlot reverseRemoveAssociation: ownerObject to: otherObject
]

{ #category : #accessing }
FMRelationSlot >> resolveSlotNamed: aName for: anObject [

	^ anObject slotNamed: aName ifFound: [ :a | a ] ifNone: [ 
		  FMVirtualSlot new
			  slotName: aName asSymbol;
			  yourself ]
]

{ #category : #internal }
FMRelationSlot >> reverseAddAssociationFrom: ownerObject to: otherObject [

	self subclassResponsibility
]

{ #category : #internal }
FMRelationSlot >> reverseRemoveAssociation: ownerObject to: otherObject [

	self subclassResponsibility
]

{ #category : #accessing }
FMRelationSlot >> targetClass [

	targetClass isSymbol
		ifTrue: [ 
			targetClass := self class environment at: targetClass 
				ifAbsent: [ self error: 'Cannot find class ', targetClass printString ] ].
	
	^targetClass
]

{ #category : #accessing }
FMRelationSlot >> targetClassName [
	^ targetClass isSymbol ifTrue: [ targetClass ] ifFalse: [ targetClass name ]
]

{ #category : #testing }
FMRelationSlot >> type: aTargetClassOrSymbol opposite: anInverseSymbol [
	self inClass: aTargetClassOrSymbol.
	inverseName := anInverseSymbol
]
