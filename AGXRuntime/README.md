# AGXRuntime

运行时工具代码.

#####Components

- AGXProtocol

    运行时 - 协议对象.

        +allProtocols

        +protocolWithObjCProtocol:
        +protocolWithName:

        -initWithObjCProtocol:
        -initWithName:

        -objCProtocol
        -name
        -incorporatedProtocols
        -methodsRequired:instance:

- AGXIvar

    运行时 - 实例变量对象.

        +ivarWithObjCIvar:
        +instanceIvarWithName:inClass:
        +classIvarWithName:inClass:
        +instanceIvarWithName:inClassNamed:
        +classIvarWithName:inClassNamed:
        +ivarWithName:typeEncoding:
        +ivarWithName:encode:

        -initWithObjCIvar:
        -initInstanceIvarWithName:inClass:
        -initClassIvarWithName:inClass:
        -initInstanceIvarWithName:inClassNamed:
        -initClassIvarWithName:inClassNamed:
        -initWithName:typeEncoding:

        -name
        -typeName
        -typeEncoding
        -offset

- AGXProperty

    运行时 - 属性对象.

        +propertyWithObjCProperty:
        +propertyWithName:inClass:
        +propertyWithName:inClassNamed:
        +propertyWithName:attributes:

        -initWithObjCProperty:
        -initWithName:inClass:
        -initWithName:inClassNamed:
        -initWithName:attributes:

        -property
        -attributes
        -addToClass:

        -attributeEncodings
        -isReadOnly
        -isNonAtomic
        -isWeakReference
        -isEligibleForGarbageCollection
        -isDynamic
        -memoryManagementPolicy
        -getter
        -setter
        -name
        -ivarName
        -typeName
        -typeEncoding
        -objectClass

        // 属性内存策略枚举
        AGXPropertyMemoryManagementPolicy

- AGXMethod

    运行时 - 方法对象.

        +methodWithObjCMethod:
        +instanceMethodWithName:inClass:
        +classMethodWithName:inClass:
        +instanceMethodWithName:inClassNamed:
        +classMethodWithName:inClassNamed:
        +methodWithSelector:implementation:signature:

        -initWithObjCMethod:
        -initInstanceMethodWithName:inClass:
        -initClassMethodWithName:inClass:
        -initInstanceMethodWithName:inClassNamed:
        -initClassMethodWithName:inClassNamed:
        -initWithSelector:implementation:signature:

        -selector
        -selectorName
        -implementation
        -setImplementation:
        -signature

#####Category

* NSObject+AGXRuntime

        // 运行时工具方法.
        +zuxProtocols
        +enumerateZUXProtocolsWithBlock:
        -enumerateZUXProtocolsWithBlock:

        +zuxIvars
        +zuxIvarForName:
        +enumerateZUXIvarsWithBlock:
        -enumerateZUXIvarsWithBlock:

        +zuxProperties
        +zuxPropertyForName:
        +enumerateZUXPropertiesWithBlock:
        -enumerateZUXPropertiesWithBlock:

        +zuxMethods
        +zuxInstanceMethodForName:
        +zuxClassMethodForName:
        +enumerateZUXMethodsWithBlock:
        -enumerateZUXMethodsWithBlock:
