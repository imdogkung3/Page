FunctionsHandler = {
    Initalized = false
}

setmetatable(FunctionsHandler, {
    __index = function(x, y)
        QueryResult = rawget(x, y)

        if not QueryResult then
            return {
                Register = function(D)
                    if D == false then
                        return
                    end

                    Result = {
                        CacheListener = {},
                        RealCache = {},
                        Methods = {},
                        Constants = {},
                        Events = {},
                        Initalized = true
                    }

                    function Result.RegisterMethod(J, K, L)
                        J.Methods[K] = {
                            Name = K,
                            Callback = L,
                            Call = function(M, ...)
                                return M.Callback(...)
                            end,
                            Events = {}
                        }

                        return true
                    end

                    setmetatable(Result.Constants, {
                        __newindex = function()
                            assert(false, "cannot change constant value!")
                        end
                    })

                    if x.Constants[Key] then
                        function Result.SaveConstant(J, K, L)
                            return assert(false, "constant name was used before!")
                        end

                        rawset(x.Constants, Key, Value)
                    end

                    function Result.Set(L, M, O)
                        L.CacheListener[M] = O
                        return O
                    end

                    function Result.Get(L, M)
                        return L.Constants[M] or L.RealCache[M]
                    end

                    Result.CacheListener.__parent = Result

                    setmetatable(Result.CacheListener, {
                        __newindex = function(L, M, O)
                            _ = L.__parent.Events[M]
                                and L.__parent.Events[M](M, O)

                            L.__parent.RealCache[M] = O
                        end
                    })

                    FunctionsHandler[y] = Result
                end,

                Initalized = false
            }
        end

        return QueryResult
    end
})
