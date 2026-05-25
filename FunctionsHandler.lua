local FunctionsHandler = {
    Initalized = false
}

setmetatable(FunctionsHandler, {
    index = function(Self, Name)
        local Result = rawget(Self, Name)

        if not Result then
            Result = {
                CacheListener = {},
                RealCache = {},
                Methods = {},
                Constants = {},
                Events = {},
                Initalized = true
            }

            function Result.Register(State)
                if State == false then
                    return
                end

                return true
            end

            function Result.RegisterMethod(SelfData, MethodName, Callback)
                SelfData.Methods[MethodName] = {
                    Name = MethodName,
                    Callback = Callback,

                    Call = function(MethodData, ...)
                        return MethodData.Callback(...)
                    end,

                    Events = {}
                }

                return true
            end

            function Result.SaveConstant(SelfData, ConstantName, ConstantValue)
                if SelfData.Constants[ConstantName] then
                    return error("constant name was used before!")
                end

                SelfData.Constants[ConstantName] = ConstantValue
            end

            function Result.Set(SelfData, CacheName, Value)
                local Event = SelfData.Events[CacheName]

                if Event then
                    Event(CacheName, Value)
                end

                SelfData.RealCache[CacheName] = Value

                return Value
            end

            function Result.Get(SelfData, CacheName)
                return SelfData.Constants[CacheName]
                    or SelfData.RealCache[CacheName]
            end

            Result.CacheListener.Parent = Result

            setmetatable(Result.CacheListener, {
                newindex = function(Table, CacheName, Value)
                    local Parent = Table.Parent
                    local Event = Parent.Events[CacheName]

                    if Event then
                        Event(CacheName, Value)
                    end

                    Parent.RealCache[CacheName] = Value
                end
            })

            rawset(Self, Name, Result)
        end

        return Result
    end
})

FunctionsHandler.LocalPlayerController.Register()
FunctionsHandler.ExpRedeem.Register()
FunctionsHandler.LevelFarm.Register()
FunctionsHandler.SniperFruit.Register()
FunctionsHandler.Pole.Register()
FunctionsHandler.Saber.Register()
FunctionsHandler.Yama.Register()
FunctionsHandler.Tushita.Register()
FunctionsHandler.CursedDualKatana.Register()
FunctionsHandler.SkullGuitar.Register()
FunctionsHandler.PullLever.Register()
FunctionsHandler.SecondSeaPuzzle.Register()
FunctionsHandler.ColosseumPuzzle.Register()
FunctionsHandler.Trevor.Register()
FunctionsHandler.EvoRaceV2.Register()
FunctionsHandler.EvoRaceV3.Register()
FunctionsHandler.ThirdSeaPuzzle.Register()
FunctionsHandler.PirateRaid.Register()
FunctionsHandler.RaidController.Register()
FunctionsHandler.MeleesController.Register()
FunctionsHandler.BossesTask.Register()
FunctionsHandler.SpecialBossesTask.Register()
FunctionsHandler.CollectFruit.Register()
FunctionsHandler.CollectBerry.Register()
FunctionsHandler.UtillyItemsActivitation.Register()                        return true
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

FunctionsHandler.LocalPlayerController:Register()
FunctionsHandler.ExpRedeem:Register()
FunctionsHandler.LevelFarm:Register()
FunctionsHandler.SniperFruit:Register()
FunctionsHandler.Pole:Register()
FunctionsHandler.Saber:Register()
FunctionsHandler.Yama:Register()
FunctionsHandler.Tushita:Register()
FunctionsHandler.CursedDualKatana:Register()
FunctionsHandler.SkullGuitar:Register()
FunctionsHandler.PullLever:Register()
FunctionsHandler.SecondSeaPuzzle:Register()
FunctionsHandler.ColosseumPuzzle:Register()
FunctionsHandler.Trevor:Register()
FunctionsHandler.EvoRaceV2:Register()
FunctionsHandler.EvoRaceV3:Register()
FunctionsHandler.ThirdSeaPuzzle:Register()
FunctionsHandler.PirateRaid:Register()
FunctionsHandler.RaidController:Register()
FunctionsHandler.MeleesController:Register()
FunctionsHandler.BossesTask:Register()
FunctionsHandler.SpecialBossesTask:Register()
FunctionsHandler.CollectFruit:Register()
FunctionsHandler.CollectBerry:Register()
FunctionsHandler.UtillyItemsActivitation:Register()
