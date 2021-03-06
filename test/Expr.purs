module Test.Expr where

import Prelude (($), bind)
import Prelude as P
import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Free (Free)

import Test.Unit.Main (runTest)
import Test.Unit.Console (TESTOUTPUT)
import Test.Unit (TestF, suite, test)
import Test.Unit.Assert as Assert

import Expr

----------------------------------------------------------------------
-- Test Infrastructure

type TestSuite = forall t. Free (TestF t) P.Unit

is      :: forall t1. Boolean -> Aff t1 P.Unit
is       = Assert.equal true
aint    :: forall t1. Boolean -> Aff t1 P.Unit
aint     = Assert.equal false

----------------------------------------------------------------------
-- Tests, I guess

testExpr :: String -> Expr
testExpr s = Equal (Const "foo") (Const s) || Prefix (Const "bar") (Const s)

main :: forall t1.
    Eff (console :: CONSOLE, testOutput :: TESTOUTPUT | t1) P.Unit
main = runTest do
    suite "eval" do
        test "equal"        $ is   $ eval empty (abc == abc)
        test "!equal"       $ aint $ eval empty (abc == def)
        test "prefix long"  $ is   $ eval empty (Prefix abc abcde)
        test "or"           $ is   $ eval empty
                                        ((Prefix abc abcde) || (xyz == abcde))
    suite "textExpr" do
        test "nothing"      $ aint $ eval empty (testExpr "nothing")
        test "foo"          $ is   $ eval empty (testExpr "foo")
        test "barbam"       $ is   $ eval empty (testExpr "barbam")
    suiteIsPrefixOf
    where
        abc     = Const "abc"
        def     = Const "def"
        abcde   = Const "abcde"
        xyz     = Const "xyz"

suiteIsPrefixOf :: TestSuite
suiteIsPrefixOf = suite "isPrefixOf" do
        test "prefix nothin"$ is   $    "" `isPrefixOf`  ""
        test "prefix short" $ aint $ "abc" `isPrefixOf`  "ab"
        test "prefix equal" $ is   $ "abc" `isPrefixOf`  "abc"
        test "prefix long"  $ is   $ "abc" `isPrefixOf`  "abcde"
        test "prefix wrong" $ aint $ "abx" `isPrefixOf`  "abcde"
