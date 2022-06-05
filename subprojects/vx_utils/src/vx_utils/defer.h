#pragma once

/*  This defer implementation comes from the gb library present in the odin compiler.
*   This is the licence for this code.
*
*   Copyright (c) 2016-2022 Ginger Bill. All rights reserved.
*
*   Redistribution and use in source and binary forms, with or without
*   modification, are permitted provided that the following conditions are met:
*
*   1. Redistributions of source code must retain the above copyright notice, this
*      list of conditions and the following disclaimer.
*
*   2. Redistributions in binary form must reproduce the above copyright notice,
*      this list of conditions and the following disclaimer in the documentation
*      and/or other materials provided with the distribution.
*
*   3. Neither the name of the copyright holder nor the names of its
*      contributors may be used to endorse or promote products derived from
*      this software without specific prior written permission.
*
*   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
*   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
*   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
*   DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
*   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
*   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
*   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
*   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
*   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
*   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

namespace vx {

template <typename T> struct _defer_remove_reference       { typedef T Type; };
template <typename T> struct _defer_remove_reference<T &>  { typedef T Type; };
template <typename T> struct _defer_remove_reference<T &&> { typedef T Type; };

/// NOTE(bill): "Move" semantics - invented because the C++ committee are idiots (as a collective not as indiviuals (well a least some aren't))
template <typename T> inline T &&_defer_forward(typename _defer_remove_reference<T>::Type &t)   { return static_cast<T &&>(t); }
template <typename T> inline T &&_defer_forward(typename _defer_remove_reference<T>::Type &&t)  { return static_cast<T &&>(t); }
template <typename T> inline T &&_defer_move   (T &&t)                                          { return static_cast<typename _defer_remove_reference<T>::Type &&>(t); }

template <typename F>
struct _PrivDefer {
	F f;
	_PrivDefer(F &&f) : f(_defer_forward<F>(f)) {}
	~_PrivDefer() { f(); }
};

template <typename F> _PrivDefer<F> _defer_func(F &&f) { return _PrivDefer<F>(_defer_forward<F>(f)); }

#define _VX_DEFER_1(x, y) x##y
#define _VX_DEFER_2(x, y) _VX_DEFER_1(x, y)
#define _VX_DEFER_3(x)    _VX_DEFER_2(x, __COUNTER__)
#define VX_DEFER(code)    auto _VX_DEFER_3(_defer_) = vx::_defer_func([&]()->void{code;})

}