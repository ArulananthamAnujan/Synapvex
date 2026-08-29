import { BarChart3, BookOpen, Check, Cloud, GraduationCap, LockKeyhole, Mic2, Users2 } from 'lucide-react';

type ProductMotionVisualProps = {
  variant: 'learn' | 'pte' | 'crm' | 'network';
  compact?: boolean;
};

const dots = Array.from({ length: 7 });

export default function ProductMotionVisual({ variant, compact = false }: ProductMotionVisualProps) {
  return (
    <div
      className={`product-motion product-motion--${variant} ${compact ? 'product-motion--compact' : ''}`}
      aria-hidden="true"
    >
      <div className="product-motion__glow" />
      <div className="product-motion__orbit">
        {dots.map((_, index) => <i key={index} style={{ '--dot': index } as React.CSSProperties} />)}
      </div>

      {variant === 'learn' && (
        <>
          <div className="product-motion__panel product-motion__panel--back">
            <span className="product-motion__chip"><GraduationCap /></span>
            <span className="product-motion__line product-motion__line--wide" />
            <span className="product-motion__line" />
          </div>
          <div className="product-motion__panel product-motion__panel--front">
            <div className="product-motion__top"><BookOpen /><b>Course studio</b></div>
            <div className="product-motion__progress"><span /></div>
            <div className="product-motion__metric"><b>12</b><small>active lessons</small></div>
            <span className="product-motion__success"><Check /> Published</span>
          </div>
        </>
      )}

      {variant === 'pte' && (
        <>
          <div className="product-motion__panel product-motion__panel--back product-motion__score">
            <small>Speaking score</small><strong>82</strong><span>+6 this week</span>
          </div>
          <div className="product-motion__panel product-motion__panel--front">
            <div className="product-motion__top"><Mic2 /><b>AI practice</b></div>
            <div className="product-motion__wave">
              {[32, 58, 42, 78, 55, 88, 66, 40, 72, 48].map((height, index) => (
                <i key={index} style={{ height: `${height}%`, animationDelay: `${index * -80}ms` }} />
              ))}
            </div>
            <div className="product-motion__status"><i /> Analysing fluency</div>
          </div>
        </>
      )}

      {variant === 'crm' && (
        <>
          <div className="product-motion__panel product-motion__panel--back product-motion__people">
            <Users2 /><span><b>248</b><small>active clients</small></span>
          </div>
          <div className="product-motion__panel product-motion__panel--front">
            <div className="product-motion__top"><BarChart3 /><b>Client pipeline</b></div>
            <div className="product-motion__columns">
              {[46, 72, 58, 88].map((height, index) => <i key={index} style={{ height: `${height}%` }} />)}
            </div>
            <div className="product-motion__status"><i /> 18 cases progressing</div>
          </div>
        </>
      )}

      {variant === 'network' && (
        <>
          <div className="product-motion__sphere">
            <span /><span /><span />
            <Cloud className="product-motion__cloud" />
          </div>
          <div className="product-motion__satellite product-motion__satellite--one"><LockKeyhole /></div>
          <div className="product-motion__satellite product-motion__satellite--two"><Check /></div>
          <div className="product-motion__network-label"><i /> Systems connected</div>
        </>
      )}

      <style>{`
        .product-motion{position:relative;min-height:270px;isolation:isolate;perspective:900px;transform-style:preserve-3d;overflow:hidden;border-radius:24px;background:radial-gradient(circle at 70% 22%,rgba(56,189,248,.19),transparent 34%),linear-gradient(145deg,#071d31,#0b3453 60%,#0a2239)}
        .product-motion--compact{min-height:210px;border-radius:18px}
        .product-motion__glow{position:absolute;inset:20% 12%;border-radius:999px;background:rgba(56,189,248,.22);filter:blur(35px);animation:pm-breathe 5s ease-in-out infinite}
        .product-motion__orbit{position:absolute;left:50%;top:50%;width:76%;height:58%;border:1px solid rgba(125,211,252,.22);border-radius:50%;transform:translate(-50%,-50%) rotateX(64deg) rotateZ(-14deg);animation:pm-orbit 16s linear infinite;transform-style:preserve-3d}
        .product-motion__orbit i{--angle:calc(var(--dot) * 51.42deg);position:absolute;left:50%;top:50%;width:5px;height:5px;border-radius:50%;background:#7dd3fc;box-shadow:0 0 14px #38bdf8;transform:rotate(var(--angle)) translateX(118px)}
        .product-motion__panel{position:absolute;width:68%;padding:16px;border:1px solid rgba(255,255,255,.2);border-radius:16px;background:linear-gradient(145deg,rgba(255,255,255,.96),rgba(224,242,254,.88));box-shadow:0 28px 55px -22px rgba(0,0,0,.75);color:#0f2f49;backdrop-filter:blur(12px);transform-style:preserve-3d}
        .product-motion__panel--front{left:12%;top:22%;animation:pm-front 6s ease-in-out infinite}
        .product-motion__panel--back{right:7%;top:12%;width:54%;opacity:.76;transform:translateZ(-60px) rotateY(-10deg);animation:pm-back 7s ease-in-out infinite}
        .product-motion__top{display:flex;align-items:center;gap:8px;font-size:12px}.product-motion__top svg{width:17px;height:17px;color:#0284c7}
        .product-motion__chip{display:grid;width:32px;height:32px;place-items:center;border-radius:10px;background:#0c4a6e;color:white}.product-motion__chip svg{width:17px}
        .product-motion__line{display:block;width:48%;height:6px;margin-top:9px;border-radius:9px;background:#bae6fd}.product-motion__line--wide{width:78%}
        .product-motion__progress{height:7px;margin:17px 0 12px;border-radius:8px;background:#dbeafe;overflow:hidden}.product-motion__progress span{display:block;height:100%;width:74%;border-radius:inherit;background:linear-gradient(90deg,#0284c7,#38bdf8);animation:pm-progress 4.5s ease-in-out infinite}
        .product-motion__metric{display:flex;align-items:baseline;gap:8px}.product-motion__metric b{font-size:25px}.product-motion__metric small{font-size:9px;color:#64748b}
        .product-motion__success,.product-motion__status{display:flex;align-items:center;gap:5px;margin-top:10px;font-size:9px;font-weight:700;color:#047857}.product-motion__success svg{width:12px;height:12px}.product-motion__status i,.product-motion__network-label i{width:6px;height:6px;border-radius:50%;background:#34d399;box-shadow:0 0 8px #34d399;animation:pm-pulse 1.8s ease-out infinite}
        .product-motion__score small,.product-motion__score span{display:block;font-size:8px;color:#64748b}.product-motion__score strong{display:block;font-size:30px;line-height:1.1;color:#0369a1}
        .product-motion__wave{display:flex;height:62px;align-items:center;justify-content:center;gap:4px;margin:13px 0}.product-motion__wave i{width:5px;border-radius:8px;background:linear-gradient(#38bdf8,#0369a1);animation:pm-wave 1.2s ease-in-out infinite alternate}
        .product-motion__people{display:flex;align-items:center;gap:8px}.product-motion__people svg{width:22px}.product-motion__people span,.product-motion__people small{display:block}.product-motion__people small{font-size:8px;color:#64748b}
        .product-motion__columns{display:flex;height:76px;align-items:flex-end;gap:8px;margin:12px 0}.product-motion__columns i{flex:1;border-radius:5px 5px 2px 2px;background:linear-gradient(#38bdf8,#075985);transform-origin:bottom;animation:pm-bars 3s ease-in-out infinite alternate}.product-motion__columns i:nth-child(2){animation-delay:-.8s}.product-motion__columns i:nth-child(3){animation-delay:-1.4s}
        .product-motion__sphere{position:absolute;left:50%;top:49%;width:138px;height:138px;border-radius:50%;border:1px solid rgba(125,211,252,.5);background:radial-gradient(circle at 32% 28%,rgba(186,230,253,.82),rgba(14,116,144,.32) 35%,rgba(2,16,31,.2) 70%);box-shadow:inset -18px -20px 36px rgba(2,8,23,.6),0 0 60px rgba(14,165,233,.3);transform:translate(-50%,-50%);animation:pm-sphere 8s ease-in-out infinite}
        .product-motion__sphere span{position:absolute;inset:18%;border:1px solid rgba(186,230,253,.38);border-radius:50%;transform:rotateX(70deg)}.product-motion__sphere span:nth-child(2){inset:3% 31%;transform:rotateY(66deg)}.product-motion__sphere span:nth-child(3){inset:3% 31%;transform:rotateY(-66deg)}
        .product-motion__cloud{position:absolute;left:50%;top:50%;width:38px;height:38px;color:white;transform:translate(-50%,-50%);filter:drop-shadow(0 5px 8px rgba(0,0,0,.4))}
        .product-motion__satellite{position:absolute;display:grid;width:38px;height:38px;place-items:center;border:1px solid rgba(255,255,255,.24);border-radius:12px;background:rgba(255,255,255,.9);color:#0369a1;box-shadow:0 18px 32px -14px #000;animation:pm-satellite 5s ease-in-out infinite}.product-motion__satellite svg{width:17px}.product-motion__satellite--one{left:16%;top:22%}.product-motion__satellite--two{right:14%;bottom:22%;animation-delay:-2.2s}
        .product-motion__network-label{position:absolute;bottom:18px;left:50%;display:flex;align-items:center;gap:7px;padding:7px 11px;border:1px solid rgba(255,255,255,.16);border-radius:99px;background:rgba(3,21,37,.64);color:#dff6ff;font-size:9px;font-weight:700;transform:translateX(-50%);backdrop-filter:blur(8px)}
        @keyframes pm-front{0%,100%{transform:translate3d(0,0,45px) rotateY(-7deg) rotateX(2deg)}50%{transform:translate3d(0,-9px,58px) rotateY(-3deg) rotateX(0)}}
        @keyframes pm-back{0%,100%{transform:translate3d(0,0,-35px) rotateY(-12deg)}50%{transform:translate3d(6px,8px,-25px) rotateY(-7deg)}}
        @keyframes pm-orbit{to{transform:translate(-50%,-50%) rotateX(64deg) rotateZ(346deg)}}
        @keyframes pm-breathe{50%{opacity:.55;transform:scale(1.18)}}@keyframes pm-progress{50%{width:91%}}@keyframes pm-pulse{70%{box-shadow:0 0 0 7px transparent}}@keyframes pm-wave{to{transform:scaleY(.56);opacity:.65}}@keyframes pm-bars{to{transform:scaleY(.72)}}@keyframes pm-sphere{50%{transform:translate(-50%,-53%) rotate(5deg)}}@keyframes pm-satellite{50%{transform:translateY(-9px) rotate(4deg)}}
        @media(max-width:640px){.product-motion{min-height:235px}.product-motion--compact{min-height:190px}.product-motion__orbit i{transform:rotate(var(--angle)) translateX(90px)}}
        @media(prefers-reduced-motion:reduce){.product-motion *{animation:none!important}}
      `}</style>
    </div>
  );
}
